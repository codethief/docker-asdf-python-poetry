FROM debian:bookworm-20240926-slim AS base

RUN apt-get update && \ 
    apt-get install --yes --no-install-recommends \
        # Dependencies needed to install asdf
        ca-certificates \
        git  \
        # Dependencies needed by asdf-python/pyenv to build Python from source,
        # compare
        # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
        build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev curl git \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
        # Dependencies needed to install asdf-poetry (yup…)
        python3

# Use non-root user for security reasons
RUN useradd --user-group --create-home --shell /bin/bash user
# Need home dir for Poetry to work. (It writes its cache there during
# installation.) 

# Need Bash for .bashrc to work.
SHELL ["/bin/bash", "-c"]

ENV OUR_WORKDIR=/workdir
RUN mkdir -p $OUR_WORKDIR && chown user:user $OUR_WORKDIR

WORKDIR $OUR_WORKDIR
USER user

COPY --chown=user:user asdf_bootstrap.sh .
COPY --chown=user:user .tool-versions .

RUN ./asdf_bootstrap.sh

# Make asdf available also in non-interactive Bash shells, including all
# subsequent RUN commands and images that inherit from us.
# -- When Bash is invoked as /bin/sh:
ENV ENV="/home/user/.bashrc"
# -- When Bash is invoked as /bin/bash:
ENV BASH_ENV="/home/user/.bashrc"


COPY --chown=user:user poetry.lock .
COPY --chown=user:user poetry.toml .
COPY --chown=user:user pyproject.toml .

# Ensure poetry.lock matches pyproject.toml
RUN if ! poetry check --lock; then exit 1; fi

# https://github.com/python-poetry/poetry/issues/8761
ENV PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

RUN poetry install

# Add application code as a very last step, so that image layer cache doesn't
# get busted unnecessarily
COPY --chown=user:user src/* ./src/

CMD ["src/main.py"]
