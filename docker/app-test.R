require("RPostgreSQL")
con <- dbConnect(
    dbDriver("PostgreSQL"),
    dbname = Sys.getenv("PGDATABASE"),
    host = Sys.getenv("PGHOST"),
    port = Sys.getenv("PGPORT"),
    user = Sys.getenv("PGUSER"),
    password = Sys.getenv("PGPASSWORD")
)

query <- Sys.getenv("QUERY", "SELECT AVG(speed) AS \"Average Speed\" FROM carspeed;")
res <- dbSendQuery(con, query)
avg <- fetch(res)
print(avg)
write.csv(avg, file='/mnt/data/average.csv', row.names=FALSE)
dbClearResult(res)
dbDisconnect(con)
print("hello")
