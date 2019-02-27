FROM circleci/node:8 as base

# set up terraform
FROM base AS tf
WORKDIR /home/circleci
RUN curl https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip -o terraform_0.11.11_linux_amd64.zip
RUN unzip terraform_0.11.11_linux_amd64.zip -d terraform
# install custom terraform kubernetes provider (so we can manage k8s deployments in tf
RUN curl -L https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/v1.3.0-custom/terraform-provider-kubernetes_v1.3.0-custom_linux_amd64.zip -o terraform-provider-kubernetes_v1.3.0-custom_linux_amd64.zip
RUN unzip terraform-provider-kubernetes_v1.3.0-custom_linux_amd64.zip -d tf-k8s
RUN ls tf-k8s

# copy tf from intermediate layer
FROM base AS final
WORKDIR /usr/bin
COPY --from=tf /home/circleci/terraform .
# ensure binary exists
RUN ls /usr/bin/terraform
RUN mkdir ~/.terraform.d
RUN mkdir ~/.terraform.d/plugins
COPY --from=tf /home/circleci/tf-k8s/ /home/circleci/.terraform.d/plugins/
# ensure plugin exists
RUN ls ~/.terraform.d/plugins/*

ENV HELM_VERSION="v2.12.3"

RUN export CLOUD_SDK_REPO="cloud-sdk-jessie" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN sudo apt-get update \
    && sudo apt-get install -y google-cloud-sdk kubectl \
    && sudo apt-get -y autoclean
RUN sudo curl -L https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz
RUN sudo tar -xzO linux-amd64/helm -f helm.tar.gz > ~/helm \
    && sudo mv ~/helm /usr/local/bin/helm \
    && sudo chmod +x /usr/local/bin/helm
RUN helm init --client-only

WORKDIR /home/circleci
