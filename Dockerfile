FROM circleci/node:10 as base

#####
FROM base AS tf
WORKDIR /home/circleci
RUN export TF_VERSION="0.12.31" \
  && curl https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o terraform_${TF_VERSION}_linux_amd64.zip \
  && unzip terraform_${TF_VERSION}_linux_amd64.zip -d terraform

#####
FROM base AS final
COPY --from=tf /home/circleci/terraform /usr/bin/terraform
RUN ls /usr/bin/terraform

RUN sudo apt-get update \
  && sudo apt-get install apt-transport-https ca-certificates gnupg gawk postgresql-client jq \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
  && sudo apt-get update \
  && sudo apt-get upgrade -y \
  && sudo apt-get install -y google-cloud-sdk \
  && sudo apt-get -y autoclean

WORKDIR /home/circleci
