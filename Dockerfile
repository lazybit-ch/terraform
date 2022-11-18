FROM ubuntu:22.04

ARG TERRAFORM_VERSION
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION:-1.3.5}

ARG GOOGLE_CLOUD_SDK_VERSION
ENV GOOGLE_CLOUD_SDK_VERSION=${GOOGLE_CLOUD_SDK_VERSION:-410.0.0-0}

ARG JQ_VERSION
ENV JQ_VERSION=${JQ_VERSION:-1.6}

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https=2.4.8 \
        ca-certificates=20211016 \
        curl=7.81.0-1ubuntu1.6 \
        git=1:2.34.1-1ubuntu1.5 \
        gnupg-utils=2.2.27-3ubuntu2.1 \
        gnupg-l10n=2.2.27-3ubuntu2.1 \
        gnupg1=1.4.23-1.1build1 \
        gpg-agent=2.2.27-3ubuntu2.1 \
        gpgconf=2.2.27-3ubuntu2.1 \
        gpg=2.2.27-3ubuntu2.1 \
        unzip=6.0-26ubuntu3.1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        google-cloud-sdk=${GOOGLE_CLOUD_SDK_VERSION} \
        google-cloud-sdk-app-engine-python=${GOOGLE_CLOUD_SDK_VERSION} \
        google-cloud-sdk-app-engine-python-extras=${GOOGLE_CLOUD_SDK_VERSION} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/

RUN curl -Lo terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip -d /usr/local/bin terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN curl -Lo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 && \
    chmod 755 /usr/local/bin/jq

ENTRYPOINT ["/usr/local/bin/terraform"]
CMD ["-help"]
