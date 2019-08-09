FROM circleci/node:8 as base

# set up terraform
FROM base AS tf
WORKDIR /home/circleci
RUN curl https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip -o terraform_0.12.6_linux_amd64.zip
RUN unzip terraform_0.12.6_linux_amd64.zip -d terraform

# copy tf from intermediate layer
FROM base AS final
WORKDIR /usr/bin
COPY --from=tf /home/circleci/terraform .
# ensure binary exists
RUN ls /usr/bin/terraform

ENV HELM_VERSION="v2.12.3"

RUN export CLOUD_SDK_REPO="cloud-sdk-jessie" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN sudo apt-get update \
    && sudo apt-get upgrade -y \
    && sudo apt-get install -y google-cloud-sdk kubectl gawk \
    && sudo apt-get -y autoclean
RUN sudo curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz
RUN sudo tar -xzO linux-amd64/helm -f helm.tar.gz > ~/helm \
    && sudo mv ~/helm /usr/local/bin/helm \
    && sudo chmod +x /usr/local/bin/helm
RUN helm init --client-only

WORKDIR /home/circleci
