FROM google/cloud-sdk AS base

# set up terraform
FROM google/cloud-sdk AS tf
RUN apt-get -qqy update && apt-get install -qqy unzip
RUN curl https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o terraform_0.11.7_linux_amd64.zip
RUN unzip terraform_0.11.7_linux_amd64.zip -d terraform
# install custom terraform kubernetes provider (so we can manage k8s deployments in tf
RUN curl -L https://github.com/sl1pm4t/terraform-provider-kubernetes/releases/download/v1.1.0-custom/terraform-provider-kubernetes_v1.1.0-custom_linux_amd64.zip -o terraform-provider-kubernetes_v1.1.0-custom_linux_amd64.zip
RUN unzip terraform-provider-kubernetes_v1.1.0-custom_linux_amd64.zip -d tf-k8s

# copy tf from intermediate layer
FROM base AS final
WORKDIR /usr/bin
COPY --from=tf /terraform .
RUN mkdir ~/.terraform.d
RUN mkdir ~/.terraform.d/plugins
COPY --from=tf /tf-k8s /root/.terraform.d/plugins

WORKDIR /

