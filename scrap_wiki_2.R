source('setup.R')

#data import
NAWL <- read.csv( file="nawl_analysis.csv", header=TRUE, sep=";", fileEncoding="windows-1250")
nawlJSON <- data.frame( id=integer(), declension=factor(), score=factor() )
#target_categories <- c('A', 'S','F', 'D')
#NAWL %<>% select(lp, word, category) %>% filter( category == target_categories )


updateSynonyms <- function( page_html ) {
  page_html -> page_html
  synonyms_once <- page_html %>% html_nodes( xpath = synonyms_xpath ) %>% html_text()
  synonyms_once <- gsub( '.*[[:space:]].*', '#', synonyms_once )
  synonyms_once <- synonyms_once[ synonyms_once != c('#','') ] %>% unlist(use.names = FALSE)
  if( !is.null( synonyms_once ) ) 
    synonyms <<- c( synonyms, synonyms_once) %>% unique() 
}

getDeclension <- function( page_html ) {
  page_html -> page_html
  form_class <- page_html %>% html_nodes( xpath = form_class_xpath ) %>% html_text()
  declension_df <- page_html %>% html_node( xpath = declension_xpath ) %>% html_table( fill = TRUE )
  declension_df %<>% as.data.frame() %>% set_names( make.unique( names(.) ) ) 
  if( length( i <- grep( "czasownik", form_class[ 1 ] ) ) ) {
    if( length( i <- grep( "dk.", form_class[ 1 ] ) ) 
        & !length(i <- grep( "dk. brak", form_class[ 1 ] ) ) ){
      form_word <<- "czasownik"
      gsub( ".*dk\\. (.+?)\\).*", "\\1", form_class[ 1 ] ) %>% getWords() %>% return()
    } else { 
      declension_df %<>% select( contains( "forma" ) | starts_with( "liczba" ) )
      declension_df %<>% filter( forma %in% conjugation_forms )  %>% return()
    }
  } else if( length( i <- grep( "przymiotnik|rzeczownik", form_class[ 1 ] ) ) ){
    if( length( i <- grep( "przymiotnik", form_class[ 1 ] ) ) )
        form_word <<- "przymiotnik"
    else form_word <<- "rzeczownik"
    declension_df %<>% select( contains( "przypadek" ) | starts_with( "liczba" ) )
    declension_df %<>% filter( przypadek %in% declension_forms )  %>% return()
  } 
}

getWords <- function( word ) {
  word <- word
  url <- paste(wiki_href, word, sep = "")
  tryCatch(
      expr = {
        page_html <- url %>% read_html()
        Sys.sleep( 1 )
        updateSynonyms( page_html )
        return ( getDeclension( page_html ) )
      },
      error = function( e ) { 
        print( e )
      }
  )
}

retrieve <- function( word ) {
  tryCatch(
    expr = {
      print( word )
      declension <- word %>% getWords()
      declension %<>% select( starts_with( "liczba" ) )
      declension %<>% unlist( use.names = FALSE) %>% unique()
      #declension %<>% paste( collapse=',' ) 
      return( declension )
    },
    error = function( e ){ 
      print( e )
    }
  )
}

appendDeclension <- function( id, declension, category ) {
  dfa <- data.frame( id=id, declension = declension, form = form_word, category = category )
  write.table( dfa,  
               file = "./declension.csv", 
               append = T, 
               sep = ';', 
               row.names = F, 
               col.names = F, fileEncoding = "windows-1250" )
}

#nrow( NAWL )
for(row in 1:3){

  synonyms <<- NULL
  NAWLrow <- NAWL[ row, ]
  
  declension <- NAWLrow$word %>% retrieve

  appendDeclension( row, declension, NAWLrow$category )
  
  if( is.null( synonyms ) ) {
    print('INFO - SYNONYMS SKIPPED')  
    next
  }
  
  for( i in 1:scrap_depth ){
    synonyms_2nd <- synonyms
    synonyms <<- NULL
    if( !is.null( synonyms_2nd ) )
      for( synonym in synonyms_2nd ) {
        declension <- retrieve( synonym ) 
        appendDeclension( row, declension, NAWLrow$category )
      }
  }
  
  #TO JSON:
  #df <- data.frame( id = NAWL$lp[ row ], declension = declension, score = NAWLrow$category )
  #df$declension <- df$declension %>% strsplit( ',' )
  #View(df)
  #nawlJSON <- rbind( nawlJSON, df )
}

#Save extended NAWL to JSON
#toJSON( nawlJSON, encoding = "UTF-8", pretty = TRUE) %>% write("nawl_extended_2.json" )






