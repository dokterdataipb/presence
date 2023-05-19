library(mongolite)

message("Set timezone")
Sys.setenv(TZ = "Asia/Bangkok")

navbarPage(
  title = 'Presensi SOT II',
  tabPanel('Peserta',    
     uiOutput("loadPeserta"),
     actionButton("absenPesertaButton", "Hadir!"),
     actionButton("resetPesertaButton", "Reset"),
     hr(),
     DT::dataTableOutput('tblPeserta')
  ),
  tabPanel('Panitia',    
     uiOutput("loadPanitia"),
     actionButton("absenPanitiaButton", "Hadir!"),
     actionButton("resetPanitiaButton", "Reset"),
     hr(),
     DT::dataTableOutput('tblPanitia'),
  )
)

