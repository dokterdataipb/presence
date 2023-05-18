mongoConnect <- function(col){
  db = Sys.getenv("MONGO_CLOUD_DB")
  url = Sys.getenv("MONGO_CLOUD_URL")
  mongo(collection=col, db=db, url=url)
}

loadTabelPeserta <- function(){
  collection_agenda_presensi <- mongoConnect("agenda_presensi")
  collection_agenda <- mongoConnect("agenda")
  collection_peserta <- mongoConnect("peserta")
  
  tbl_agenda_presensi <- collection_agenda_presensi$find()
  tbl_agenda <- collection_agenda$find()
  tbl_peserta <- collection_peserta$find()
  
  tbl_comb <- merge(tbl_peserta, tbl_agenda_presensi, by.x=0, by.y="id_peserta")
  tbl_comb <- subset(tbl_comb, select = c(nama, tanggal, waktu))
  tbl_comb
}

function(input, output) {
  tblRV <- reactiveValues(
    tbl_comb_panitia = loadTabelPeserta(), tbl_comb_peserta = data.frame()
  )
  
  listPanitia <- reactive({
    collection_peserta <- mongoConnect("peserta")
    tbl_peserta <- collection_peserta$find('{"tipe": 1}')
    collection_peserta$disconnect()
    
    setNames(tbl_peserta$id_peserta, tbl_peserta$nama)
  })
  
  listPeserta <- reactive({
    collection_peserta <- mongoConnect("peserta")
    tbl_peserta <- collection_peserta$find('{"tipe": 2}')
    tbl_peserta$tipe <- NULL
    collection_peserta$disconnect()
    
    setNames(tbl_peserta$id_peserta, tbl_peserta$nama)
  })
  
  output$loadPeserta <- renderUI({
    selectInput("namaPeserta", "Nama Peserta", c(listPeserta()))
  })
  
  output$loadPanitia <- renderUI({
    selectInput("namaPanitia", "Nama Panitia", listPanitia())
  })
  
  
  observeEvent(input$absenPanitiaButton, {
    collection_agenda_presensi <- mongoConnect("agenda_presensi")
    newdocument <- data.frame(id_peserta=input$namaPanitia, id_agenda=1, tanggal=format(Sys.time(), "%a %d %b %Y"), waktu=format(Sys.time(), "%X"))
    collection_agenda_presensi$insert(newdocument)
    
    tblRV$tbl_comb_panitia <- loadTabelPeserta()
  })
  
  # display 10 rows initially
  output$tblPanitia <- DT::renderDataTable({
    DT::datatable(tblRV$tbl_comb_panitia, options = list(pageLength = 25))
  })
  
}

