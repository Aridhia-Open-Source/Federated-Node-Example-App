require("RPostgreSQL")
con <- dbConnect(
    dbDriver("PostgreSQL"),
    dbname = Sys.getenv("PGDATABASE"),
    host = Sys.getenv("PGHOST"),
    port = Sys.getenv("PGPORT"),
    user = Sys.getenv("PGUSER"),
    password = Sys.getenv("PGPASSWORD")
)

query <- Sys.getenv("QUERY", "SELECT AVG(speed) FROM carspeed;")
res <- dbSendQuery(con, query)
write.csv(fetch(res), file='/mnt/data/average.csv', row.names=FALSE)
