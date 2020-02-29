FROM postgres:11.5 

COPY ./init.sql /docker-entrypoint-initdb.d/init.sql
ADD init.sql /docker-entrypoint-initdb.d
RUN chmod a+r /docker-entrypoint-initdb.d/*
