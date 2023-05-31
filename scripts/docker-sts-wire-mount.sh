#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
PWFILE="${ROOTDIR}/pw-file"
FILE="${ROOTDIR}/config.yml"
WLFILE="${ROOTDIR}/scripts/put-client-in-whitelist.sh"
if [ -f "$FILE" ]; then
  docker run --name=sts-wire-client$1 \
           --net=host -d \
           --device /dev/fuse \
           --cap-add SYS_ADMIN \
           --privileged \
           -v $HOME/.config/oidc-agent:/home/docker/.config/oidc-agent \
           -v "${ROOTDIR}/certs/certs-client$1/private.key":/home/docker/private.key \
           -v "${ROOTDIR}/certs/certs-client$1/public.crt":/home/docker/public.crt \
           -v "${WLFILE}":/home/docker/put-client-in-whitelist.sh \
           -v "${FILE}":/home/docker/config.yml \
           -v "${PWFILE}":/home/docker/pw-file \
           ffornari/sts-wire-rados \
           sh -c -x \
           'mkdir -p rgw .cache && \
           nice -n 19 sts-wire --config config.yml \
           --localCache full --tryRemount --noDummyFileCheck \
           --localCacheDir .cache \
           &>"mount_log_sts-wire.txt" & sleep 3s && \
           eval `oidc-agent` && oidc-add --pw-file=pw-file docker-admin-ds-119 && \
           ./put-client-in-whitelist.sh \
           "$(grep -m1 client_id $HOME/sts-wire.log | jq -r '"'"'.body'"'"' | jq -r '"'"'.client_id'"'"')" && \
           curl -s -L -X GET -c cookies.txt --cert public.crt --key private.key \
           "https://ds-119.cr.cnaf.infn.it/dashboard?x509ClientAuth=true" > /dev/null 2>&1 && \
           EXCHANGE_URI=$(curl -vvv -b cookies.txt \
           --cert public.crt --key private.key --stderr - \
           "$(cat sts-wire.log | grep authorize | jq -r '"'"'.message'"'"')" \
           | grep -m1 Location | awk -F'"'"' '"'"' '"'"'{print $3}'"'"' | tr -d '"'"'\r'"'"') && \
           oidc-gen --pw-file=pw-file --codeExchange="${EXCHANGE_URI}"; \
           tail -f /dev/null'
fi
