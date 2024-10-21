library("DBI")
library("odbc")
library("RODBC")

connection_string <- paste0(
    'driver={ODBC Driver 18 for SQL Server}',
    ';server=', Sys.getenv("PGHOST"),
    ';database=', Sys.getenv("PGDATABASE"),
    ';uid=', Sys.getenv("PGUSER"),
    ';pwd=', Sys.getenv("PGPASSWORD"),
    ';TrustServerCertificate=Yes',
    sep=''
)

conn <- odbcDriverConnect(connection_string)
res <- sqlQuery(conn, 'SELECT * FROM omop.person')
print(res)
write.csv(res, file='/mnt/data/average.csv', row.names=FALSE)
odbcCloseAll()
