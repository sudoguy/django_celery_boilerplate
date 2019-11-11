FROM python:3.7-alpine

RUN mkdir /install
WORKDIR /install

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    python3-dev \
    libc-dev \
    linux-headers \
    openssl-dev \
    && \
    apk add --no-cache \
    postgresql-dev

RUN pip install -U pip
RUN pip install --pre poetry

RUN poetry config virtualenvs.create false

COPY poetry.lock pyproject.toml /

RUN poetry install --no-dev

RUN apk del --no-cache .build-deps

COPY . /app

WORKDIR /app
