#1/usr/bin/env bash

export DJANGO_SETTINGS_MODULE=chronam.settings

log "setup chronam as a django application"
django-admin.py syncdb --noinput --migrate
django-admin.py chronam_sync --skip-essays
django-admin.py collectstatic --noinput
