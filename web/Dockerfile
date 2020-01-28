FROM python:3.7.5

WORKDIR /usr/src/django

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /usr/src/django/
COPY ./startup /usr/src/django/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

ARG MODE=false
RUN if [ "$MODE" = "true" ] ; then ln -s /usr/src/django/startup/test.sh /bin/launch-django; else ln -s /usr/src/django/startup/runserver.sh /bin/launch-django; fi

CMD launch-django
