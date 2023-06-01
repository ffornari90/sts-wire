#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
PWFILE="${ROOTDIR}/pw-file"
FILE="${ROOTDIR}/config.yml"
WLFILE="${ROOTDIR}/scripts/put-client-in-whitelist.sh"
if [ -f "$FILE" ]; then
  docker run --name=sts-wire-client$1 \
           --net=host -d --rm \
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
           sh -c 'mkdir -p rgw && \
           nice -n 19 sts-wire --config config.yml \
           --localCache full --tryRemount --noDummyFileCheck & sleep 3s && \
           eval `oidc-agent` && oidc-add --pw-file=pw-file docker-admin-ds-119 && \
           ./put-client-in-whitelist.sh \
           "$(grep -m1 client_id sts-wire.log | jq -r '"'"'.body'"'"' | jq -r '"'"'.client_id'"'"')" \
           > /dev/null 2>&1 && curl -s -L -X GET -c cookies.txt --cert public.crt --key private.key \
           "https://ds-119.cr.cnaf.infn.it/dashboard?x509ClientAuth=true" > /dev/null 2>&1 && \
           string="$(cat sts-wire.log | grep authorize | jq -r '"'"'.message'"'"')" && \
           substring="&audience=$(cat config.yml | grep audience | awk '"'"'{print $2}'"'"')" && \
           result="$string$substring" && EXCHANGE_URI=$(curl -vvv -b cookies.txt \
           --cert public.crt --key private.key --stderr - "${result}" \
           | grep -m1 Location | awk -F'"'"' '"'"' '"'"'{print $3}'"'"' | tr -d '"'"'\r'"'"') && \
           curl -s "${EXCHANGE_URI}" > /dev/null 2>&1 && \
           tail -f /dev/null'
fi
