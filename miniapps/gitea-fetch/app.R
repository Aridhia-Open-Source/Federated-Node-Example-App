library(shiny)
library(httr)
library(jsonlite)
if (!require("shinyjs")) install.packages("shinyjs")
if (!require("shinycssloaders")) install.packages("shinycssloaders")

repos <- c(
  "argocd/fn-trigger"='argocd/fn-triggers'
)

# Generated from the gitea UI and stored as a workspace secret
token <- Sys.getenv("GITEA_TOKEN")
# this will be the the hub domain i.e. gitea.uksouth.preview.aridhia.io
giteaHost <- "gitea."
# Add a proxy exception
if(! grepl(giteaHost, Sys.getenv("no_proxy"), fixed=TRUE))
  Sys.setenv(no_proxy=paste(Sys.getenv("no_proxy"), giteaHost, sep=","))

# Define UI for the application
ui <- fluidPage(
  # Provide a title
  titlePanel("Gitea Results fetcher"),
  sidebarLayout(
    sidebarPanel(
      # Add reactive elements here
      selectInput("repo", "Repository:", repos),
      selectInput("branch", "Branch", c("main")),
      textInput("file", "File", placeholder="file to fetch"),
      textInput("folder", "Folder", placeholder="Download path", value="~/files"),
      actionButton("fetch", "Get results")
    ),
    mainPanel(
      useShinyjs(),
      # Add reactive elements here
      textOutput("resultsText")
    ),
    fluid=TRUE,
    position=c("left")
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

  # Get result action
  trigger <- function(){
    shinyjs::disable("fetch")
    #trim the path to the file name only
    outFile <- tail(str_split(input$file, "/")[[1]], n=1)

    # send a request to gitea
    res <- httr::GET(
      paste("https://", giteaHost, "/", input$repo, "/raw/branch/", input$branch, "/", input$file,"?token=", token, sep = ""),
      httr::write_disk(paste(input$folder, "/", outFile, sep=""), overwrite=TRUE),
      httr::accept("application/raw")
    )
    # If it fails, write an error
    if(httr::http_error(res))
      output$resultsText <- renderText("Failed")
    else
      output$resultsText <- renderText("Downloaded successfully")
    enable("fetch")
  }
  # Update branches names when the repo changes or is initialized
  observeEvent(input$repo, {
    res <- httr::GET(
      paste("https://", giteaHost, "/api/v1/repos/", input$repo, "/branches?token=", token, sep = ""),
    )
    jsonRespParsed<-content(res,as="parsed")
    branches <- lapply(jsonRespParsed, function(x){x$name})
    updateSelectInput(session, "branch", choices=branches)
  }, ignoreInit = FALSE)

  onclick("fetch", trigger())
}

# Run the application
shinyApp(ui = ui, server = server)
