FROM ubuntu:20.04

ARG DEBIAN_FRONTEND="noninteractive"

# set the variables as per $(pyenv init -)
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    PATH="/opt/pyenv/shims:/opt/pyenv/bin:$PATH" \
    PYENV_ROOT="/opt/pyenv" \
    PYENV_SHELL="bash"

ADD build-deps /tmp/build-deps
ADD requirements.txt /tmp/requirements.txt
ADD python-versions /tmp/python-versions

RUN apt-get update && \
    xargs -a /tmp/build-deps apt-get install -y --no-install-recommends && \
    curl --location https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash && \
    pyenv update && \
    for version in `cat /tmp/python-versions`; do pyenv install $version; done && \
    xargs -a /tmp/python-versions pyenv global && \
    pyenv rehash && \
    pip3 install --upgrade pip && \
    pip3 install -r /tmp/requirements.txt && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find ${PYENV_ROOT}/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rfv '{}' + && \
    find ${PYENV_ROOT}/versions -type f '(' -name '*.py[co]' -o -name '*.exe' ')' -exec rm -fv '{}' +

CMD ["tox"]
LABEL name=tox maintainer="nagy.attila@gmail.com"
