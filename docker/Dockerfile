FROM rocker/shiny-verse:4.3.2

RUN apt-get update \
    && apt install libpq-dev wget odbcinst unixodbc -y \
    && R -e "install.packages(c(\"RPostgreSQL\",\"RODBC\",\"odbc\",\"DBI\", repo=\"https://cloud.r-project.org\"))" \
    && wget -q https://packages.microsoft.com/ubuntu/20.04/prod/pool/main/m/msodbcsql18/msodbcsql18_18.4.1.1-1_amd64.deb \
    && yes | dpkg -i msodbcsql18_18.4.1.1-1_amd64.deb

COPY app-test.R /app-test.R
ENTRYPOINT [ "Rscript", "/app-test.R" ]
