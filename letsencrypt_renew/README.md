# letsencrypt renew

This DAG renews Letsencrypt certificates using certbot.

If certificates are renewed, NGINX is reload to pick up the new ones and
prosody imports the new certificates and realods too.

## TODO

I should probably only realod services when their specific certificates have
been renewed.
