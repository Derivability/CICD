FROM python:3.7.5

WORKDIR /usr/src/django

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /usr/src/django/requirements.txt
RUN pip install --upgrade pip && pip install -r requirements.txt

CMD echo TEST
