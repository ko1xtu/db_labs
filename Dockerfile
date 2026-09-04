# Общий Containerfile
FROM docker.io/library/postgres:alpine3.22

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres

# Лаб 1 - Создание таблиц
COPY scripts/init.sql /docker-entrypoint-initdb.d/01_init.sql
