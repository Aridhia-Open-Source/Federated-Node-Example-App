library("DBI")
library("odbc")
library("RODBC")
library("stringr")

resBasePath <- '/mnt/data'
host <- str_replace(Sys.getenv("PGHOST"), "http://", "")
host <- str_replace(host, "https://", "")

connection_string <- paste0(
    'driver={ODBC Driver 18 for SQL Server}',
    ';server=', host,
    ';database=', Sys.getenv("PGDATABASE"),
    ';uid=', Sys.getenv("PGUSER"),
    ';pwd=', Sys.getenv("PGPASSWORD"),
    ';TrustServerCertificate=Yes',
    sep=''
)

conn <- odbcDriverConnect(connection_string)
res <- sqlQuery(conn, 'SELECT * FROM omop.person')
write.csv(res, file='/mnt/data/average.csv', row.names=FALSE)
odbcCloseAll()
