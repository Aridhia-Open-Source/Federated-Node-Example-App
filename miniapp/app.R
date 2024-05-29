library(shiny)
if (!require("shinyjs")) install.packages("shinyjs")
if (!require("shinycssloaders")) install.packages("shinycssloaders")
library(httr)
library(jsonlite)

token <- Sys.getenv("PHEMS_FN_Demo_Dataset_2238")


# Define UI for the application
ui <- fluidPage(
  useShinyjs(),
    # Provide a title
    titlePanel("Federated Node Task Runner"),
    tags$head(tags$script(src = "fnrequest.js")),
    selectInput("image", "Analytics to run:",
        c("Average values" = "arihdia-federated-node/rocker-r-ver:4.3")
    ),
    actionButton("task", "Run Task!"),
    actionButton("status", "check status", disabled = TRUE),
    actionButton("results", "Get results", disabled = TRUE),

    textOutput("task_id"),
    textOutput("task_status"),
    textOutput("results"),
    span(textOutput("fn_error"), style="color:red;")
)

# Define server logic for the application
server <- function(input, output, session) {
  task_id <- NULL
    sendTask <- function(image){
      shinyjs::disable("task")
      headers = c(
        'Authorization' = paste("Bearer", token),
        "Content-Type" = "application/json"
      )
      body <- list(
        name = "Test Task",
        executors = list(
          list(
            image="arihdia-federated-node/rocker-r-ver:4.3",
            command=c(
              "R",
              "-e",
              "df <- as.data.frame(installed.packages())[,c('Package', 'Version')];write.csv(df, file='/mnt/data/packages.csv', row.names=FALSE);Sys.sleep(10)"
            ),
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
      print(resp)
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
      print("getStatus")
      disable("status")
      headers = c(
        'Authorization' = paste("Bearer", token)
      )
      print(paste("https://qc-federatednode.qc.aridhiatest.net/tasks/", task_id, sep = ""))
      res <- VERB(
        "GET",
        url = paste("https://qc-federatednode.qc.aridhiatest.net/tasks/", task_id, sep = ""),
        add_headers(headers)
      )
      resp <- content(res, 'parsed')

      if (http_status(res)[["category"]] == "Success"){
        print(resp[["status"]])
        print(typeof(resp[["status"]]))
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
    getResults <- function(){
      disable("results")
      headers = c(
        'Authorization' = paste("Bearer", token)
      )
      res <- httr::GET(
        paste("https://qc-federatednode.qc.aridhiatest.net/tasks/", task_id, "/results", sep = ""),
        add_headers(headers),
        httr::write_disk(paste("task", task_id, ".tar.gz", sep = ""), overwrite=TRUE),
        httr::accept("*/*")
      )

      if (http_status(res)[["category"]] == "Success"){
        enable("task")
        task_id <<- resp[['task_id']]
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
    onclick("results", getResults())
}

# Run the application
shinyApp(ui = ui, server = server)
