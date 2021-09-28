ARG PHP_BASE_IMAGE

FROM ${PHP_BASE_IMAGE}

ENV BANNER_IMAGE_NAME="Beach PHP" \
    BEACH_APPLICATION_PATH="/application" \
    SUPERVISOR_BASE_PATH="/opt/flownative/supervisor" \
    BEACH_CRON_BASE_PATH="/opt/flownative/beach-cron" \
    SITEMAP_CRAWLER_BASE_PATH="/opt/flownative/sitemap-crawler" \
    SSHD_BASE_PATH="/opt/flownative/sshd" \
    SSHD_ENABLE="false"

USER root

COPY root-files /

COPY --from=blackfire/blackfire:2 /usr/local/bin/blackfire /opt/flownative/php/bin/

COPY --from=hipages/php-fpm_exporter:2 /php-fpm_exporter /opt/flownative/php/bin/php-fpm-exporter

RUN export FLOWNATIVE_LOG_PATH_AND_FILENAME=/dev/stdout \
    && /build.sh init \
    && /build.sh build \
    && /build.sh clean

USER 1000

EXPOSE 2022 9000 9001 9002

WORKDIR ${BEACH_APPLICATION_PATH}
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "run" ]
