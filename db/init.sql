CREATE USER django_user WITH ENCRYPTED PASSWORD 'django_unleashed';
CREATE DATABASE django_db OWNER django_user;
ALTER USER django_user CREATEDB;
