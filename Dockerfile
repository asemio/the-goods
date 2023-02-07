FROM alpine:3.17
WORKDIR /root

ENV TF_VERSION '0.12.31'
ENV TF_ZIP "terraform_${TF_VERSION}_linux_amd64.zip"
ENV GCLOUD_TAR 'google-cloud-sdk-416.0.0-linux-x86_64.tar.gz'

RUN apk update \
  # Warning: these are the dependencies needed to complete the execution of this Dockerfile ONLY
  # Further runtime dependencies go into launch.sh
  && apk add --no-cache curl bash unzip python3 ca-certificates gnupg \
    # These ones are an exception because they're small enough and it saves some startup time
    git gawk jq coreutils openssh-client

SHELL ["/bin/bash", "-c"]

RUN echo 'export PS1="\w\\$ "' >> "$HOME/.bashrc" \
  # TERRAFORM \
  && curl "https://releases.hashicorp.com/terraform/${TF_VERSION}/$TF_ZIP" -o "$TF_ZIP" \
  && unzip "$TF_ZIP" \
  && rm -r "$TF_ZIP" \
  # GCLOUD
  && curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$GCLOUD_TAR" \
  && tar xzf "$GCLOUD_TAR" \
  && rm "$GCLOUD_TAR" \
  && pushd google-cloud-sdk \
    && ./install.sh --additional-components beta --rc-path /root/.bashrc --usage-reporting false --quiet \
  && popd \
  # COMPRESS
  && tar czf tools.tar.gz terraform google-cloud-sdk \
  && rm -r terraform google-cloud-sdk

COPY launch.sh .

ENTRYPOINT [ "/root/launch.sh" ]
