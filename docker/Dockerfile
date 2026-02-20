FROM ghcr.io/aridhia-open-source/r-base:0.0.1

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

COPY app-test.R /app-test.R
ENTRYPOINT [ "Rscript", "/app-test.R" ]
