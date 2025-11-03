library(shiny)
library(httr)
library(jsonlite)
if (!require("htmltools")) install.packages("htmltools")
if (!require("bslib")) install.packages("bslib")
if (!require("shinyjs")) install.packages("shinyjs")
if (!require("shinycssloaders")) install.packages("shinycssloaders")

fnToken <- Sys.getenv("FNTOKEN")
datasetBody <- list(
  name = Sys.getenv("PGDATABASE"),
  host = Sys.getenv("PGUSER"),
  username = Sys.getenv("PGPASSWORD"),
  password = Sys.getenv("PGHOST")
)
baseURLFN <- Sys.getenv("FNURL")
# Define UI for the application
ui <- page_fillable(
  useShinyjs(),
  theme = bs_theme(
    bg = parseCssColors("#222249ff"),
    fg = parseCssColors("#d1d6e0ff"),
    primary = parseCssColors("#b3b000ff"),
    secondary = parseCssColors("#a73c3cff"),
  ),
  title = "Federated Node Mapper",
  fluidRow(
    column(8, align="center",
      textInput("acrUrl", "Container Registry URL"),
      textInput("acrUsername", "Container Registry username"),
      passwordInput("acrToken", "Container Registry token"),
      actionButton("connectFN", "Connect to FN", class = "btn-lg btn-success"),
    )
  )
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
  onclick("connectFN", function() {
    showPageSpinner()
    output$fn_error <- renderText("")
    disable("connectFN")

    # Validate the form contents
    if (any(c(input$acrUrl, input$acrUsername, input$acrToken) == "")){
      enable("connectFN")
      hidePageSpinner()
      showErrorModal("Missing mandatory fields")
      return()
    }

    # Prepare request headers
    headers = c(
      'Authorization' = paste("Bearer", fnToken),
      'Content-Type' = 'application/json'
    )

    val<- sendRequest(
      url = paste(baseURLFN, "/datasets", sep = ""),
      headers = headers,
      body = datasetBody
    )
    if (is.null(val)) {
      return()
    }

    sendRequest(
      url = paste(baseURLFN, "/registries", sep = ""),
      headers = headers,
      body = list(
          url = input$acrUrl,
          username = input$acrUsername,
          password = input$acrToken
        )
    )

    enable("connectFN")
    hidePageSpinner()
  })
}

sendRequest <- function(url, headers, body) {
  ListJSON=toJSON(body, pretty=TRUE, auto_unbox=TRUE)
  tryCatch(
    {
      res <- httr::POST(
      url,
      body=ListJSON,
      add_headers(headers)
    )
    data <- content(res, as = "parsed", type = "application/json")
        if (http_status(res)[["category"]] == "Success"){
          print(data)
        } else {

          showErrorModal(data[["error"]])
          return()
        }
    },
    error=function(e){
      error_message <- paste(conditionMessage(e), collapse = "\n")

      showErrorModal(paste("Request Failed:", error_message, sep = "\n"))
      return()
    },
    warning=function(w){
      warning_message <- paste(conditionMessage(w), collapse = "\n")

      showErrorModal(paste("Warning During Request:", warning_message, sep = "\n"))
      return()
    }
  )
}

showErrorModal <- function(message){
   hidePageSpinner()
   enable("connectFN")
   showModal(
      modalDialog(
        title = "Error",
        easy_close = TRUE,
        size = "s",
        message
      )
    )
}
# Run the application
shinyApp(ui = ui, server = server)
