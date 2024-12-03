FROM ubuntu:24.04

ARG WORKDIR=/angular
WORKDIR ${WORKDIR}

ARG NODE_VERSION=23
ARG ANGULAR_CLI_VERSION=19

ENV WORKDIR=${WORKDIR}
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=${NODE_VERSION}
ENV PATH=$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH

RUN apt-get update && apt-get install -y \
    curl \
    git \
    git-flow \
    vim \
    wget \
    gnupg \
    iputils-ping \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    software-properties-common \
    mysql-client \
    postgresql-client \
    build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \
    bash -c "source $NVM_DIR/nvm.sh && nvm install ${NODE_VERSION} && nvm use ${NODE_VERSION} && nvm alias default ${NODE_VERSION} && \
    npm install -g @angular/cli@${ANGULAR_CLI_VERSION}" 

RUN bash -c "source $NVM_DIR/nvm.sh && node -v && npm -v && ng version"

EXPOSE 4200

CMD ["/bin/bash"]