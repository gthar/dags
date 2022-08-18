# rsync letsencrypt

This DAG pulls my letsencrypt certificates from my public server that issues
and renews them using rsync.

If any certificate has been updated, it reloads my Nginx reverse proxy
instance and updates the certificates for my PostgreSQL instance.
