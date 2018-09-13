FROM circleci/node:8 as base

# set up terraform
FROM base AS tf
RUN sudo curl https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o terraform_0.11.7_linux_amd64.zip
RUN sudo unzip terraform_0.11.7_linux_amd64.zip -d terraform
# install custom terraform kubernetes provider (so we can manage k8s deployments in tf
RUN sudo curl -L https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/v1.1.0-custom/terraform-provider-kubernetes_v1.1.0-custom_linux_amd64.zip -o terraform-provider-kubernetes_v1.1.0-custom_linux_amd64.zip
RUN sudo unzip terraform-provider-kubernetes_v1.1.0-custom_linux_amd64.zip -d tf-k8s

# copy tf from intermediate layer
FROM base AS derp
WORKDIR /usr/bin
COPY --from=tf /terraform .
RUN mkdir ~/.terraform.d
RUN mkdir ~/.terraform.d/plugins
COPY --from=tf /tf-k8s /root/.terraform.d/plugins
RUN export CLOUD_SDK_REPO="cloud-sdk-jessie" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN sudo apt-get update \
    && sudo apt-get install -y google-cloud-sdk kubectl \
    && sudo apt-get -y autoclean

WORKDIR /

