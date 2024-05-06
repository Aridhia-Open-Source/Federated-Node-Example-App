library(shiny)
if (!require("shinyjs")) install.packages("shinyjs")
if (!require("shinycssloaders")) install.packages("shinycssloaders")

token <- Sys.getenv("FNTOKEN")
# Define UI for the application
ui <- fluidPage(
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
    # Add reactive elements here
)

# Define server logic for the application
server <- function(input, output, session) {
  # fix for mini_app greying-out after 10 min of inactivity
    autoInvalidate <- reactiveTimer(10000)
    observe({
        autoInvalidate()
        cat(".")
    })
    session$allowReconnect("force")
    # Add logic for reactive elements here.

    observeEvent(input$task, {
        #shinycssloaders::showPageSpinner()
        session$sendCustomMessage(type = 'submitTask',
            message = token)
        #shinycssloaders::hidePageSpinner()
    })
    observeEvent(input$status, {
        #showPageSpinner()
        session$sendCustomMessage(type = 'checkStatus', message=paste(token, input$task_id, sep=","))
        #hidePageSpinner()
    })
    observeEvent(input$task_status, {
        print(input$task_status)
    })
    observeEvent(input$results, {
        #showPageSpinner()
        session$sendCustomMessage(type = 'getResults', message=paste(token, input$task_id, sep=","))
        #hidePageSpinner()
    })
}

# Run the application
shinyApp(ui = ui, server = server)
