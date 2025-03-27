#! /bin/bash

# Install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Postgres Setup
pass=`openssl rand -base64 12` \
&& echo $pass>/run/pg_pass \
&& docker run --name postgresdb -v /data/postgres/datadir:/var/lib/postgresql/data -p 5432:5432 --restart always -e POSTGRES_PASSWORD=$pass -d postgres:${postgres_version}