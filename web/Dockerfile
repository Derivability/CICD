FROM python:latest


WORKDIR /usr/src/django

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /usr/src/django/
COPY ./startup /usr/src/django/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

CMD ./launch-django
