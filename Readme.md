This project defines the docker containers to run a 3 Node Patroni cluster on a local setup.

Two nodes patroni1, patroni2 are setup so that they can participate in a failover i.e if any one of them is acting as a primary and goes down because of any reason, the other node can automatically be promoted as a primary. These two nodes can be considered as a primary cluster deployed in one data center.

The third node is configured as only a standby replica. That means this node silently replicates data from the primary cluster and does not participate in failover.

In case of a disaster scenario, where the primary datacenter goes down, this machine can be manually promoted to a leader and accessed by application.

To run this setup locally, execute the following commands

1. docker-compose build
2. docker-compose up -d

After testing, if you want to shutdown the cluster, you can execute the following commands.
1. docker-compose down

How to vertify the setup.

Once the cluster is successfully started, you can execute the following command to make sure it lists out the nodes of the patroni cluster.

```
$ patronictl -c /etc/patroni.yml list
+ Cluster: patroni-cluster (7394471230231924760) ----+-----------+------------------+
| Member     | Host       | Role    | State     | TL | Lag in MB | Tags             |
+------------+------------+---------+-----------+----+-----------+------------------+
| patroni1   | patroni1   | Leader  | running   |  4 |           |                  |
| patroni2   | patroni2   | Replica | streaming |  4 |         0 |                  |
| patroni_dr | patroni_dr | Replica | streaming |  4 |         0 | nofailover: true |
+------------+------------+---------+-----------+----+-----------+------------------+
```

To verify the replication, from the primary node (patroni1 in the above example), connect to the local postgres instance and create sample data.

`$ psql -h localhost -p 5432`

Enter the password when prompted

-- On the leader node, execute the following
```
CREATE TABLE test_replication (id serial PRIMARY KEY, data text);
INSERT INTO test_replication (data) VALUES ('Test data 1'), ('Test data 2');
```

-- On standby and DR nodes, execute the following to make sure the above data is available.

`SELECT * FROM test_replication;`

To test the DR scenario, 

Bring down the two Patroni nodes using the following command.

`docker-compose stop patroni1  patroni2`

If you check the patroni cluster status using the following, the patroni_dr node will still be running but not promoted as a leader.

$ patronictl -c /etc/patroni.yml list

At this instance, we can not write to the database

To manually promote the dr node, you need to execute the following command on the DR node.

`pg_ctl promote -D /var/lib/postgresql/data`

Now patroni_dr will become the leader and accepts the writes also.


