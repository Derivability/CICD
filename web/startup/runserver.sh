#!/bin/bash

#Migrate
python manage.py makemigrations
python manage.py migrate

cat <<EOF | python manage.py shell
from django.contrib.auth import get_user_model

User = get_user_model()  # get the currently active user model,

User.objects.filter(username='$DJANGO_ADMIN').exists() or \
    User.objects.create_superuser('$DJANGO_ADMIN', 'admin@example.com', '$DJANGO_ADMIN_PASS')
EOF

#Start server
python manage.py runserver 0.0.0.0:8000
