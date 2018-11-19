FROM google/cloud-sdk AS base
RUN apt-get -qqy update && apt-get install -qqy unzip
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -qqy nodejs

# set up terraform
FROM base AS tf
RUN curl https://releases.hashicorp.com/terraform/0.11.9/terraform_0.11.9_linux_amd64.zip -o terraform_0.11.9_linux_amd64.zip
RUN unzip terraform_0.11.9_linux_amd64.zip -d terraform

# copy tf from intermediate layer
FROM base AS final
WORKDIR /usr/bin
COPY --from=tf /terraform .

WORKDIR /
