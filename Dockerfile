ARG PHP_BASE_IMAGE

FROM ${PHP_BASE_IMAGE}
MAINTAINER Robert Lemke <robert@flownative.com>

LABEL org.label-schema.name="Beach PHP"
LABEL org.label-schema.description="Docker image providing PHP for Beach and Local Beach"
LABEL org.label-schema.vendor="Flownative GmbH"

COPY --from=docker.pkg.github.com/flownative/bash-library/bash-library:1 /lib $FLOWNATIVE_LIB_PATH

ENV FLOWNATIVE_LIB_PATH="/opt/flownative/lib" \
    BEACH_APPLICATION_PATH="/application" \
    SSHD_BASE_PATH="/opt/flownative/sshd" \
    SSHD_ENABLE="false" \
    LOG_DEBUG="false"

USER root

COPY root-files /
RUN /build.sh init \
    && /build.sh build \
    && /build.sh clean

USER 1000

EXPOSE 2022 9000 9001
WORKDIR ${BEACH_APPLICATION_PATH}
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "run" ]
