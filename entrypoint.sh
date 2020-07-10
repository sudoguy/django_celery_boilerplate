#!/usr/bin/env sh

# set -o errexit
# set -o nounset

python /app/manage.py migrate --noinput
python /app/manage.py collectstatic --noinput

uwsgi --ini uwsgi.ini

# /usr/local/bin/gunicorn django_celery_boilerplate.wsgi \
#   --workers=4 `# Sync worker settings` \
#   --max-requests=2000 \
#   --max-requests-jitter=400 \
#   --bind='0.0.0.0:8000' `# Run Django on 8000 port` \
#   --chdir='/app'       `# Locations` \
#   --log-file=- \
#   --worker-tmp-dir='/dev/shm'
