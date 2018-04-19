FROM google/cloud-sdk AS base

# set up terraform
FROM google/cloud-sdk AS tf
RUN apt-get -qqy update && apt-get install -qqy unzip
RUN curl https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o terraform_0.11.7_linux_amd64.zip
RUN unzip terraform_0.11.7_linux_amd64.zip -d terraform

FROM base AS final
WORKDIR /usr/bin
COPY --from=tf /terraform .

WORKDIR /

