library(mongolite)

message("Set timezone")
Sys.setenv(TZ = "Asia/Bangkok")

# navbarPage(
#   title = 'Presensi SOT II',
#   tabPanel('Peserta',    
#      uiOutput("loadPeserta"),
#      actionButton("absenPesertaButton", "Hadir!"),
#      actionButton("resetPesertaButton", "Reset"),
#      hr(),
#      DT::dataTableOutput('tblPeserta')
#   ),
#   tabPanel('Panitia',    
#      uiOutput("loadPanitia"),
#      actionButton("absenPanitiaButton", "Hadir!"),
#      actionButton("resetPanitiaButton", "Reset"),
#      hr(),
#      DT::dataTableOutput('tblPanitia'),
#   )
# )

panitia_ui <- function(){
  fluidRow(
    column(width=4,
      uiOutput("loadPanitia"),
      actionButton("absenPanitiaButton", "Hadir!"),
      # actionButton("resetPanitiaButton", "Reset"),
      downloadButton("downloadPanitiaButton", "Download")
    ),
    column(width=8,
      DT::dataTableOutput('tblPanitia')
    )
  )
}

peserta_ui <- function(){
  fluidRow(
    column(width=4,
      uiOutput("loadPeserta"),
      selectInput("sesiAcara", "Acara", 
                  c("Sesi 1"=1, "Sesi 2"=2, "Sesi 3"=3, "Sesi 4"=4)),
      actionButton("absenPesertaButton", "Hadir!"),
      # actionButton("resetPesertaButton", "Reset"),
      downloadButton("downloadPesertaButton", "Download")
    ),
    column(width=8,
      DT::dataTableOutput('tblPeserta')
    )
  )
}

htmlTemplate(
  filename = "www/index.html",
  panitia_ui = panitia_ui(),
  peserta_ui = peserta_ui()
)

