FROM rocker/shiny-verse:4.3.2

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        curl \
        unixodbc \
        unixodbc-dev \
        libodbc2 \
        odbc-postgresql \
        libmariadb3 \
        libgtk2.0-0 \
        libgtk-3-0 \
        libaio1

RUN apt-get update \
    && apt install libpq-dev -y \
    && R -e "install.packages(c(\"DBI\", \"RPostgreSQL\", \"odbc\"), repo=\"https://cloud.r-project.org\")"

# MS SQL
RUN curl -sSL -O https://packages.microsoft.com/config/ubuntu/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18

# MySQL
RUN wget https://dev.mysql.com/get/Downloads/Connector-ODBC/9.3/mysql-connector-odbc_9.3.0-1ubuntu22.04_amd64.deb \
    && dpkg -i mysql-connector-odbc_9.3.0-1ubuntu22.04_amd64.deb \
    && rm mysql-connector-odbc_9.3.0-1ubuntu22.04_amd64.deb \
    && mkdir /usr/lib/odbc \
    && ln -s /usr/lib/x86_64-linux-gnu/odbc/libmyodbc9w.so /usr/lib/odbc/libmyodbc9w.so \
    && ln -s /usr/lib/x86_64-linux-gnu/odbc/libmyodbc9a.so /usr/lib/odbc/libmyodbc9a.so

# MariaDB
RUN wget https://dlm.mariadb.com/4189209/Connectors/odbc/connector-odbc-3.2.5/mariadb-connector-odbc_3.2.5-1+maria~jammy_amd64.deb \
    && dpkg -i mariadb-connector-odbc_3.2.5-1+maria~jammy_amd64.deb \
    && rm mariadb-connector-odbc_3.2.5-1+maria~jammy_amd64.deb \
    && ln -s /usr/lib/x86_64-linux-gnu/libmaodbc.so /usr/lib/odbc/libmaodbc.so \
    && echo "[MariaDB ODBC 3.2 Driver]" >> /etc/odbcinst.ini \
    && echo "Description=MariaDB Connector/ODBC v.3.0" >> /etc/odbcinst.ini \
    && echo "DRIVER=/usr/lib/odbc/libmaodbc.so" >> /etc/odbcinst.ini \
    && echo "UsageCount=1" >> /etc/odbcinst.ini

# Oracle drivers?
WORKDIR /opt/oracle
RUN wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip \
    && unzip instantclient-basic-linuxx64.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-odbc-linuxx64.zip \
    && unzip instantclient-odbc-linuxx64.zip -d odbc \
    && echo "[Oracle ODBC Driver]" >> /etc/odbcinst.ini \
    && echo "Description=OracleDB Connector/ODBC v.23.8" >> /etc/odbcinst.ini \
    && echo "DRIVER=/opt/oracle/odbc/instantclient_23_8/libsqora.so.23.1" >> /etc/odbcinst.ini \
    && echo "UsageCount=1" >> /etc/odbcinst.ini \
    && echo "/opt/oracle/instantclient_23_8" | sudo tee /etc/ld.so.conf.d/oracle.conf \
    && ldconfig \
    && rm *.zip

WORKDIR /

COPY app-test.R /app-test.R
ENTRYPOINT [ "Rscript", "/app-test.R" ]
