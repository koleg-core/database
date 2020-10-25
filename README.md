# database

Database configs driven by postgress.


## Setup databases

```bash
make init
```
Username: `postgress`
Password: secret you need kubectl to get it

Note: Normally these credentials are secrets but for the
## To have access to database:

### Develop db
*Documentation from `helm status db-develop -n develop`*

PostgreSQL can be accessed via port 5432 on the following DNS name from within your cluster:

    db-develop-postgresql.develop.svc.cluster.local - Read/Write connection

To get the password for "postgres" run:

    export POSTGRES_PASSWORD=$(kubectl get secret --namespace develop db-develop-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)

To connect to your database run the following command:

    kubectl run db-develop-postgresql-client --rm --tty -i --restart='Never' --namespace develop --image docker.io/bitnami/postgresql:11.9.0-debian-10-r48 --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- psql --host db-develop-postgresql -U postgres -d postgres -p 5432



To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace develop svc/db-develop-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432

### Production db
*Documentation from `helm status db-production -n master`*

PostgreSQL can be accessed via port 5432 on the following DNS name from within your cluster:

    db-production-postgresql.master.svc.cluster.local - Read/Write connection

To get the password for "postgres" run:

    export POSTGRES_PASSWORD=$(kubectl get secret --namespace master db-production-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)

To connect to your database run the following command:

    kubectl run db-production-postgresql-client --rm --tty -i --restart='Never' --namespace master --image docker.io/bitnami/postgresql:11.9.0-debian-10-r48 --env="PGPASSWORD=$POSTGRES_PASSWORD" --command -- psql --host db-production-postgresql -U postgres -d postgres -p 5432

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace master svc/db-production-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432

