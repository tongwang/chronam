#!/usr/bin/env bash

export DJANGO_SETTINGS_MODULE=chronam.settings

log "setup chronam as a django application"
django-admin.py syncdb makemigrations  >> $LOG_FILE
django-admin.py syncdb migrate >> $LOG_FILE
django-admin.py chronam_sync --skip-essays >> $LOG_FILE
django-admin.py collectstatic --noinput >> $LOG_FILE
