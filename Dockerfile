# This Dockerfile has three stages:
#
# dependencies-image
#   Installs third-party dependencies (requirements/main.txt) into a virtual
#   environment. This virtual environment is ideal for copying across build
#   stages.
# install-image
#   Installs the app into the virtual environment.
# runtime-image
#   - Updates system packages using the scripts/install-runtime-packages.sh
#     script (this technique prevents the apt-get cache from being added to the
#     Docker layers).
#   - Copies the virtual environment into place.
#   - Runs a non-root user.
#   - Sets up the entrypoint and port.

FROM python:3.7-slim-buster AS dependencies-image

# Update system packages to get security updates
RUN apt-get -y update && apt-get -y upgrade
# Install git; needed to install Safir from GitHub
RUN apt-get -y install --no-install-recommends git

# Create a Python virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python -m venv $VIRTUAL_ENV
# Make sure we use the virtualenv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
# Put the latest pip and setuptools in the virtualenv
RUN pip install --upgrade --no-cache-dir pip setuptools

# Install the app's Python runtime dependencies
COPY requirements/main.txt ./requirements.txt
RUN pip install --quiet --no-cache-dir -r requirements.txt

FROM python:3.7-slim-buster AS install-image

# Update system packages to get security updates
RUN apt-get -y update && apt-get -y upgrade
# Install git (needed for setuptools_scm)
RUN apt-get -y install --no-install-recommends git

# Use the virtualenv
COPY --from=dependencies-image /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY . /app
WORKDIR /app
RUN pip install --no-cache-dir .

FROM python:3.7-slim-buster AS runtime-image

# Create a non-root user
RUN useradd --create-home appuser
WORKDIR /home/appuser

# Make sure we use the virtualenv
ENV PATH="/opt/venv/bin:$PATH"

# Update system packages
COPY scripts/install-runtime-packages.sh .
RUN ./install-runtime-packages.sh

COPY --from=install-image /opt/venv /opt/venv

# Switch to non-root user
USER appuser

EXPOSE 8080

ENTRYPOINT ["safirdemo", "run", "--port", "8080"]
