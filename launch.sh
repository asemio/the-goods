#! /usr/bin/env bash

echo 'Starting asemio/the-goods ...'

pushd /root > /dev/null
  tar xzf tools.tar.gz
  mv terraform /usr/bin/
  source .bashrc
popd > /dev/null

if [ "$#" -eq 0 ] && [ -z "$CIRCLE_BRANCH" ]; then
  bash
elif [ "$#" -eq 1 ] && [ "$1" = 'install' ]; then
  # install extra deps
  apk update && apk add --no-cache postgresql-client npm nodejs docker
else
  "$@"
fi
