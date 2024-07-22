FROM postgres:15

RUN apt-get update && \
    apt-get install -y python3-pip python3-dev libpq-dev && \
    apt-get install -y python3-psycopg2 python3-etcd && \
    apt-get install -y patroni

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a script to initialize the data directory
RUN echo '#!/bin/bash\n\
if [ ! -s "$PGDATA/PG_VERSION" ]; then\n\
    mkdir -p "$PGDATA"\n\
    chown postgres:postgres "$PGDATA"\n\
    chmod 700 "$PGDATA"\n\
fi\n\
exec patroni /etc/patroni.yml\n\
' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

# Ensure PGDATA directory exists and has correct permissions
RUN mkdir -p "$PGDATA" && chown postgres:postgres "$PGDATA" && chmod 700 "$PGDATA"

USER postgres

# Set the default command to run when starting the container
CMD ["/docker-entrypoint.sh"]