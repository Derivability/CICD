FROM python:3.7.5

WORKDIR /usr/src/django

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN pip install --upgrade pip
COPY ./requirements.txt /usr/src/django/requirements.txt
RUN pip install -r requirements.txt

COPY . /usr/src/django/
CMD echo TEST
