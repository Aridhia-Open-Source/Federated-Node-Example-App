require("DBI")

con <- dbConnect(odbc::odbc(),
    .connection_string = Sys.getenv("CONNECTION_STRING")
)

query <- Sys.getenv("QUERY", "SELECT AVG(speed) AS \"Average Speed\" FROM carspeed;")
res <- dbSendQuery(con, query)
avg <- dbFetch(res)
print(avg)
write.csv(avg, file='/mnt/data/average.csv', row.names=FALSE)
dbClearResult(res)
dbDisconnect(con)
