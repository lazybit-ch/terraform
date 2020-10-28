FROM ubuntu:20.04

ARG TERRAFORM_VERSION
ENV TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.13.5}

ARG GOOGLE_CLOUD_SDK_VERSION
ENV GOOGLE_CLOUD_SDK_VERSION=${GOOGLE_CLOUD_SDK_VERSION:-316.0.0-0}

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https=2.0.2 \
        ca-certificates=20201027ubuntu0.20.04.1 \
        curl=7.68.0-1ubuntu2.2 \
        git=1:2.25.1-1ubuntu3 \
        gnupg=2.2.19-3ubuntu2 \
        unzip=6.0-25ubuntu1 && \
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

ENTRYPOINT ["/usr/local/bin/terraform"]
CMD ["-help"]
