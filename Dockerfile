FROM alpine:3.8
MAINTAINER Fabian Beuke <mail@beuke.org>

# Set Timezone
ENV TIMEZONE Asia/Jakarta
RUN apk update && apk add --no-cache tzdata ca-certificates \
  && cp /usr/share/zoneinfo/`echo $TIMEZONE` /etc/localtime && \
  apk del tzdata

RUN apk add --update --no-cache \
  xvfb \
  libgcc libstdc++ libx11 glib libxrender libxext libintl \
  libcrypto1.0 libssl1.0 \
  ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family

# on alpine static compiled patched qt headless wkhtmltopdf (47.2 MB)
# compilation takes 4 hours on EC2 m1.large in 2016 thats why binary
COPY wkhtmltopdf /usr/bin

RUN mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin && \
  echo $'#!/usr/bin/env sh\n\
  Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \n\
  DISPLAY=:0.0 wkhtmltopdf-origin $@ \n\
  killall Xvfb\
  ' > /usr/bin/wkhtmltopdf

RUN chmod +x /usr/bin/wkhtmltopdf
RUN chmod +x /usr/bin/wkhtmltopdf-origin
