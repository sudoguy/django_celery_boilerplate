FROM python:3.8-slim as development_build

ARG ENV="production"

ENV ENV=${ENV} \
    DEBIAN_FRONTEND=noninteractive \
    # poetry:
    POETRY_VERSION=1.0.9 \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_CACHE_DIR='/var/cache/pypoetry' \
    # pip:
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

# System deps
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    python3-dev \
    build-essential \
    curl \
    git \
    gettext \
    # Cleaning cache:
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    # Installing `poetry` package manager:
    # https://github.com/python-poetry/poetry
    && pip install "poetry==$POETRY_VERSION"

WORKDIR /app
# Copy only requirements, to cache them in docker layer
COPY ./pyproject.toml ./poetry.lock /app/

# Project initialization:
RUN echo "$ENV" \
    && poetry --version \
    && poetry install \
    $(if [ "$ENV" = 'production' ]; then echo '--no-dev'; fi) \
    --no-interaction --no-ansi \
    # Do not install the root package (the current project)
    --no-root \
    # Cleaning poetry installation's cache for production:
    && if [ "$ENV" = 'production' ]; then rm -rf "$POETRY_CACHE_DIR"; fi

# Setting up proper permissions:
RUN groupadd -r web && useradd -d /app -r -g web web \
    && chown web:web -R /app

# Running as non-root user:
USER web

COPY . /app

CMD ["sh", "entrypoint.sh"]
