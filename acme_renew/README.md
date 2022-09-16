# acme renew

This DAG renews wildcard certificates using `acme.sh`.

If a renewal happens, reload the nginx instance and deploy certificates to the
PostgreSQL instance.

The Nginx instance has the actual certificate files mounted as read-only
mounts, so it doesn't need any explicit deployment, just a reload.

PostgreSQL complains if the certificates are mounted as read-only, so I opted
for making a copy of the files to volume used by PostgreSQL because I don't
like mouting the actual original files with write permissions to any container
other than the acme.sh one.
On the other hand, PostgreSQL doesn't need to be reloaded to pick the new
files.
