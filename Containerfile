FROM quay.io/fedora/fedora-minimal:39

RUN microdnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
  && microdnf -y install ffmpeg just jq \
  && mkdir -p /unlock_aax/{config,staging,production}

COPY bin/* /unlock_aax/
COPY config/* /unlock_aax/config/

VOLUME /unlock_aax/config
VOLUME /unlock_aax/staging
VOLUME /unlock_aax/production

WORKDIR /unlock_aax