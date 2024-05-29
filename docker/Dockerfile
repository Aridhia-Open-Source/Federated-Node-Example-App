FROM rocker/shiny-verse:4.3.2

RUN apt-get update \
    && apt install libpq-dev -y \
    && R -e "install.packages(\"RPostgreSQL\", repo=\"https://cloud.r-project.org\")"

COPY app-test.R /app-test.R
ENTRYPOINT [ "Rscript", "/app-test.R" ]
