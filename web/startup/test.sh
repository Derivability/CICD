#!/bin/bash

#Migrate
python manage.py makemigrations
python manage.py migrate

#Run tests
python manage.py test polls || echo "test failed" > ../failed.err
