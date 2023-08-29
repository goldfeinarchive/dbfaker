FROM python:3.11-buster as builder


ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    POETRY_VERSION=1.6.1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    POETRY_NO_ANSI=1 \
    \
	# Tell Poetry where to place its cache and virtual environment
    POETRY_CACHE_DIR=/tmp/poetry_cache


WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN touch README.md

# Install dependencies
RUN --mount=type=cache,target=$POETRY_CACHE_DIR poetry install --without dev --no-root

FROM python:3.11-slim-buster as runtime

# Efficient locations to write to host file system.  Specify the mount point using
# docker run --volume=$(somepath):/data
VOLUME /data

# Copy Dependencies
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
COPY dbfaker ./dbfaker

ENTRYPOINT ["python", "-m", "dbfaker.main"]
CMD ["--version"]