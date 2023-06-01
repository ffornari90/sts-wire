FROM ubuntu:latest
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y \
    ca-certificates curl wget gettext-base gpg gpg-agent git make golang patch build-essential fuse fio && \
    DEBIAN_FRONTEND=noninteractive apt clean && \
    curl repo.data.kit.edu/repo-data-kit-edu-key.gpg | apt-key add - && \
    echo "deb https://repo.data.kit.edu/debian/stable ./" > /etc/apt/sources.list.d/kit.list && \
    wget "http://repository.egi.eu/sw/production/cas/1/current/tgz/" && \
    mkdir tgz certificates && for tgz in $(cat index.html | awk -F'"' '{print $2}' | grep tar.gz); \
    do wget http://repository.egi.eu/sw/production/cas/1/current/tgz/$tgz -O tgz/$tgz; \
    done && for tgz in $(ls tgz/); do tar xzf tgz/$tgz --strip-components=1 -C certificates/; \
    done && for f in $(find certificates/ -type f -name "*.pem"); \
    do cat $f >> /etc/ssl/certs/ca-certificates.crt; done && \
    wget "https://crt.sh/?d=2475254782" -O /etc/ssl/certs/geant-ov-rsa-ca.crt && \
    cat /etc/ssl/certs/geant-ov-rsa-ca.crt >> /etc/ssl/certs/ca-certificates.crt && \
    rm -rf tgz certificates && \
    DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y oidc-agent && \
    DEBIAN_FRONTEND=noninteractive apt clean && \
    git clone --branch rados https://github.com/DODAS-TS/sts-wire.git && \
    cd sts-wire && make build-linux-with-rclone && mv sts-wire_linux /usr/local/bin/sts-wire && \
    cd .. && rm -rf sts-wire && adduser --disabled-password --group --system --gecos '' --home /home/docker docker
USER docker
WORKDIR /home/docker
