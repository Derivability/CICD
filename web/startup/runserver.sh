#!/bin/bash

#Migrate
python manage.py makemigrations
python manage.py migrate

cat <<EOF | python manage.py shell
from django.contrib.auth import get_user_model

User = get_user_model()  # get the currently active user model,

User.objects.filter(username='admin').exists() or \
    User.objects.create_superuser('admin', 'admin@example.com', 'pass')
EOF

#Start server
python manage.py runserver 0.0.0.0:8000
