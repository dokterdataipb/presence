mongoConnect <- function(col){
  db = Sys.getenv("MONGO_CLOUD_DB")
  url = Sys.getenv("MONGO_CLOUD_URL")
  mongo(collection=col, db=db, url=url)
}


loadTabelPeserta <- function(tipe){
  tbl_comb <- data.frame(nama=NULL, tanggal=NULL, waktu=NULL)
  
  collection_agenda_presensi <- mongoConnect("agenda_presensi")
  collection_agenda <- mongoConnect("agenda")
  collection_peserta <- mongoConnect("peserta")
  
  tbl_agenda_presensi <- collection_agenda_presensi$find()
  tbl_agenda <- collection_agenda$find()
  tbl_peserta <- collection_peserta$find()
  
  if(nrow(tbl_agenda_presensi)!=0){
    tbl_comb <- merge(tbl_peserta, tbl_agenda_presensi, by="id_peserta")
    tbl_comb <- tbl_comb[which(tbl_comb$tipe==tipe),] 
    if(tipe==2){
      tbl_comb <- subset(tbl_comb, select = c(nama, id_agenda, tanggal, waktu))
      colnames(tbl_comb) <- c("Nama", "Sesi", "Tanggal", "Waktu")
    } else {
      tbl_comb <- subset(tbl_comb, select = c(nama, tanggal, waktu))
      colnames(tbl_comb) <- c("Nama", "Tanggal", "Waktu")
    }
  }
  
  tbl_comb
}

loadPeserta <- function(tipe){
  collection_peserta <- mongoConnect("peserta")
  collection_agenda_presensi <- mongoConnect("agenda_presensi")
  
  tbl_agenda_presensi <- collection_agenda_presensi$find()
  tbl_peserta <- collection_peserta$find()
  
  tbl_peserta_filter <- collection_peserta$find(paste0('{"tipe": ', tipe, '}'))
  
  if(nrow(tbl_agenda_presensi)!=0){
    tbl_comb <- merge(tbl_peserta, tbl_agenda_presensi, by="id_peserta")
    filter <- subset(tbl_peserta_filter, !(nama %in% tbl_comb$nama))
  } else {
    filter <- tbl_peserta_filter
  }
  
  setNames(filter$id_peserta, filter$nama)
}

function(input, output) {
  tblRV <- reactiveValues(
    tbl_comb_panitia = loadTabelPeserta(1), tbl_comb_peserta = loadTabelPeserta(2),
    list_peserta = loadPeserta(2), list_panitia = loadPeserta(1)
  )
  
  output$loadPeserta <- renderUI({
    selectInput("namaPeserta", "Nama Peserta", tblRV$list_peserta)
  })
  
  output$loadPanitia <- renderUI({
    selectInput("namaPanitia", "Nama Panitia", tblRV$list_panitia)
  })
  
  
  observeEvent(input$absenPanitiaButton, {
    collection_agenda_presensi <- mongoConnect("agenda_presensi")
    newdocument <- data.frame(id_peserta=input$namaPanitia, id_agenda=1, id_tipe=1, tanggal=format(Sys.time(), "%a %d %b %Y"), waktu=format(Sys.time(), "%X"))
    collection_agenda_presensi$insert(newdocument)
    
    tblRV$tbl_comb_panitia <- loadTabelPeserta(1)
    tblRV$list_panitia = loadPeserta(1)
  })
  
  observeEvent(input$absenPesertaButton, {
    collection_agenda_presensi <- mongoConnect("agenda_presensi")
    newdocument <- data.frame(id_peserta=input$namaPeserta, id_agenda=input$sesiAcara, id_tipe=2, tanggal=format(Sys.time(), "%a %d %b %Y"), waktu=format(Sys.time(), "%X"))
    collection_agenda_presensi$insert(newdocument)
    
    tblRV$tbl_comb_peserta <- loadTabelPeserta(2)
    tblRV$list_peserta <- loadPeserta(2)
  })
  
  observeEvent(input$resetPesertaButton, {
    collection_agenda_presensi <- mongoConnect("agenda_presensi")
    collection_agenda_presensi$remove('{"id_tipe": {"$eq": 2}}')
    
    tblRV$tbl_comb_peserta <- loadTabelPeserta(2)
    tblRV$list_peserta <- loadPeserta(2)
  })
  
  observeEvent(input$resetPanitiaButton, {
    collection_agenda_presensi <- mongoConnect("agenda_presensi")
    collection_agenda_presensi$remove('{"id_tipe": {"$eq": 1}}')
    
    tblRV$tbl_comb_panitia <- loadTabelPeserta(1)
    tblRV$list_panitia <- loadPeserta(1)
  })
  
  output$tblPanitia <- DT::renderDataTable({
    DT::datatable(tblRV$tbl_comb_panitia, options = list(pageLength = 25))
  })
  
  output$tblPeserta <- DT::renderDataTable({
    DT::datatable(tblRV$tbl_comb_peserta, options = list(pageLength = 25))
  })
  
  output$downloadPanitiaButton <- downloadHandler(
    filename = function() {
      paste0("panitia.csv")
    },
    content = function(file) {
      write.csv(tblRV$tbl_comb_panitia, file)
    }
  )
  
  output$downloadPesertaButton <- downloadHandler(
    filename = function() {
      paste0("peserta.csv")
    },
    content = function(file) {
      write.csv(tblRV$tbl_comb_peserta, file)
    }
  )
  
}

