# Общий Containerfile
FROM docker.io/library/postgres:alpine3.22

ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres

# Лаб 1 - Создание таблиц
COPY scripts/lab1.sql /docker-entrypoint-initdb.d/001_init.sql

# Лаб 2.1 - манипуляции
COPY scripts/lab2/t1.sql /docker-entrypoint-initdb.d/002_init.sql
COPY scripts/lab2/t2.sql /docker-entrypoint-initdb.d/003_init.sql
COPY scripts/lab2/t3.sql /docker-entrypoint-initdb.d/004_init.sql
COPY scripts/lab2/t4.sql /docker-entrypoint-initdb.d/005_init.sql
COPY scripts/lab2/t5.sql /docker-entrypoint-initdb.d/006_init.sql

# Лаб 2.2 
COPY scripts/lab2.2/lab2.2.sql /docker-entrypoint-initdb.d/007_init.sql
COPY scripts/lab2.2/q_plans.sql /docker-entrypoint-initdb.d/008_init.sql

# Лаб 3
COPY scripts/lab3.sql /docker-entrypoint-initdb.d/009_init.sql