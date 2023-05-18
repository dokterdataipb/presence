library(mongolite)

message("Set timezone")
Sys.setenv(TZ = "Asia/Bangkok")

navbarPage(
  title = 'Presensi SOT II',
  tabPanel('Peserta',    
     uiOutput("loadPeserta"),
     actionButton("absenPesertaButton", "Hadir!"),
     DT::dataTableOutput('tblPeserta')
  ),
  tabPanel('Panitia',    
     uiOutput("loadPanitia"),
     actionButton("absenPanitiaButton", "Hadir!"),
     hr(),
     DT::dataTableOutput('tblPanitia')
  )
)

