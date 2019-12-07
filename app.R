library(shiny)

ui <- fluidPage(
  gitlink::ribbon_css(
    link = "https://github.com/gadenbuie/ms-render-ui-delay",
    text = "View on GitHub"
  ),
  wellPanel(
    class = "col-sm-11",
    tags$p(
      "This app was inspired by the discussion in",
      tags$a(href = "https://mastering-shiny.org", "Mastering Shiny"),
      "by Hadley Wickham about",
      tags$a(
        href = "https://mastering-shiny.org/action-dynamic.html#creating-ui-with-code",
        "Creating UI With Code",
        .noWS = "after"
      ),
      "."
    ),
    tags$p(
      "Add tasks using the inputs below.",
      "The task list on the left is generated in R on the server using Shiny,",
      "and the task list on the right is created in the browser using JavaScript.",
      "Repeatedly adding the same task highlights the delay between the browser",
      "to server round trip and the additional computation cost of rendering",
      "the UI on the server."
    )
  ),
  tags$div(
    class = "input-group",
    textInput("task", "New Task", value = "Something important I have to do"),
    tags$div(
      class = "btn-group",
      actionButton("add_task", "Add Task"),
      actionButton("clear_list", "Clear List")
    )
  ),
  fluidRow(
    tags$div(
      class = "col-sm-6",
      tags$h3("Task List"),
      tags$p(
        tags$em("Uses", tags$code("renderUI()"), "and is sent back to the server.")
      ),
      tags$p("You have", uiOutput("task_count", inline = TRUE), "tasks."),
      tags$ul(
        uiOutput("shiny_task_list")
      )
    ),
    tags$div(
      class = "col-sm-6",
      tags$h3("Task List"),
      tags$p(tags$em("Added here in the browser")),
      tags$p("You have", tags$span(id = "browser-task-count", 0), "tasks."),
      tags$ul(id = "browser-task-list")
    )
  ),
  tags$script(HTML(
    "
    let taskCount = 0

    document.getElementById('add_task').addEventListener('click', () => {
      const task = document.getElementById('task').value
      const ul = document.getElementById('browser-task-list')
      ul.innerHTML += `<li>${task}</li>`
      document.getElementById('browser-task-count').textContent = ++taskCount
    })

    document.getElementById('clear_list').addEventListener('click', () => {
      const ul = document.getElementById('browser-task-list')
      while (ul.firstChild) ul.removeChild(ul.firstChild)
      taskCount = 0
      document.getElementById('browser-task-count').textContent = taskCount
    })
    "
  ))
)

server <- function(input, output, session) {
  tasks <- reactiveVal(character())

  observeEvent(input$add_task, {
    req(input$task)
    tasks(c(tasks(), input$task))
  })

  observeEvent(input$clear_list, {
    tasks(character())
  })

  output$shiny_task_list <- renderUI({
    if (!length(tasks())) return(NULL)
    tagList(
      purrr::map(tasks(), tags$li)
    )
  })

  output$task_count <- renderUI(paste(length(tasks())))
}

shinyApp(ui, server)
