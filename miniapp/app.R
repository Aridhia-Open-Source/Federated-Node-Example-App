library(shiny)
library(httr)
library(jsonlite)
if (!require("shinyjs")) install.packages("shinyjs")
if (!require("shinycssloaders")) install.packages("shinycssloaders")
system("mkdir ~/results")
token <- Sys.getenv("PHEMS_FN_Demo_Dataset_2238")
commands <- list(
  "arihdia-federated-node/rtest:latest" = NULL,
  "arihdia-federated-node/rocker-r-ver:4.3" = c(
    "R",
    "-e",
    "df <- as.data.frame(installed.packages())[,c('Package', 'Version')];write.csv(df, file='/mnt/data/packages.csv', row.names=FALSE);Sys.sleep(10)"
  )
)
resultsFiles <- list(
  "arihdia-federated-node/rtest:latest" = "average.csv",
  "arihdia-federated-node/rocker-r-ver:4.3" = "packages.csv"
)

# Define UI for the application
ui <- fluidPage(
  useShinyjs(),
    # Provide a title
    titlePanel("Federated Node Task Runner"),
    tags$head(tags$script(src = "fnrequest.js")),
    selectInput("image", "Analytics to run:",
        c(
          "Average values" = "arihdia-federated-node/rtest:latest",
          "Package List" = "arihdia-federated-node/rocker-r-ver:4.3"
          )
    ),
    actionButton("task", "Run Task!"),
    actionButton("status", "check status", disabled = TRUE),
    actionButton("results", "Get results", disabled = TRUE),

    textOutput("task_id"),
    textOutput("task_status"),
    textOutput("resultsText"),
    span(textOutput("fn_error"), style="color:red;"),

    mainPanel(
      tableOutput("table")
    )
)

# Define server logic for the application
server <- function(input, output, session) {
    task_id <- NULL
    sendTask <- function(image){
      # Clear other text
      output$fn_error <- renderText("")
      output$task_status <- renderText("")
      output$results <- renderText("")
      hide("table")

      shinyjs::disable("task")
      headers = c(
        'Authorization' = paste("Bearer", token),
        "Content-Type" = "application/json"
      )
      command <- commands[[image]]

      body <- list(
        name = "Test Task",
        executors = list(
          list(
            image=image,
            command=command,
            env=list(VARIABLE_UNIQUE=123)
          ),list()
        ),
        tags=list(dataset_id = 1),
        inputs=list(),
        outputs=list(),
        resources=list(
          requests=list(cpu="0.1", memory="50Mi"),
          limits=list(cpu="100m", memory="100Mi")
        ),
        volumes=list(),
        description="This is a new task"
      )

      ListJSON=toJSON(body,pretty=TRUE,auto_unbox=TRUE)

      res <- VERB(
        "POST",
        url = "https://qc-federatednode.qc.aridhiatest.net/tasks",
        add_headers(headers),
        body=ListJSON
      )
      resp <- content(res, 'parsed')
      if (http_status(res)[["category"]] == "Success"){
        enable("status")
        task_id <<- resp[['task_id']]
        output$task_id <- renderText(paste("Created task with id:", strtoi(task_id)))
      } else {
        enable("task")
        output$fn_error <- renderText(resp[["error"]])
      }
    }
    getStatus <- function(){
      output$fn_error <- renderText("")
      print("getStatus")
      disable("status")
      headers = c(
        'Authorization' = paste("Bearer", token)
      )
      res <- VERB(
        "GET",
        url = paste("https://qc-federatednode.qc.aridhiatest.net/tasks/", task_id, sep = ""),
        add_headers(headers)
      )
      resp <- content(res, 'parsed')

      if (http_status(res)[["category"]] == "Success"){
        if (typeof(resp[["status"]]) != "list"){
          enable("status")
          output$task_status <- renderText(paste("Status:", resp[["status"]]))
          return()
        }
        else if (names(resp[["status"]]) == "terminated"){
          enable("results")
        } else {
          enable("status")
        }
        output$task_status <- renderText(paste("Status:", names(resp[["status"]])))
      } else {
        enable("status")
        output$fn_error <- renderText(resp[["error"]])
      }
    }
    getResults <- function(image){
      disable("results")
      output$fn_error <- renderText("")
      headers = c(
        'Authorization' = paste("Bearer", token)
      )
      res <- httr::GET(
        paste("https://qc-federatednode.qc.aridhiatest.net/tasks/", task_id, "/results", sep = ""),
        add_headers(headers),
        httr::write_disk(paste("~/task_", task_id, ".tar.gz", sep = ""), overwrite=TRUE),
        httr::accept("*/*")
      )

      if (http_status(res)[["category"]] == "Success"){
        enable("task")
        fileres <- paste("task_", task_id, ".tar.gz", sep = "")

        system(paste("tar -xf ~/", fileres, " -C ~/results/", sep = ""))
        data <- read.csv(paste("~/results/", task_id, "/", resultsFiles[[image]], sep = ""))

        show("table")
        output$table <- renderTable({data})
      } else {
        enable("results")
        resp <- content(res, 'parsed')
        output$fn_error <- renderText(resp[["error"]])
      }
    }
    # fix for mini_app greying-out after 10 min of inactivity
    autoInvalidate <- reactiveTimer(10000)
    observe({
        autoInvalidate()
        cat(".")
    })
    session$allowReconnect("force")
    # Add logic for reactive elements here.
    onclick("task", sendTask(input$image))
    onclick("status", getStatus())
    onclick("results", getResults(input$image))
}

# Run the application
shinyApp(ui = ui, server = server)
