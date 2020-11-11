source('setup.R')

#data import
NAWL <- read.csv( file="nawl_analysis.csv", header=TRUE, sep=";", fileEncoding="windows-1250")
nawlJSON <- data.frame( id=integer(), declension=factor(), score=factor() )
#target_categories <- c('A', 'S','F', 'D')
#NAWL %<>% select(lp, word, category) %>% filter( category == target_categories )

updateCognates <- function( page_html ) {
  page_html -> page_html
  cognates_once <- page_html %>% html_nodes( xpath = cognate_xpath ) %>% html_text()
  cognates_once <- gsub( ' się', '', cognates_once ) %>% unlist( use.names = FALSE )
  if( length( cognates_once ) > 0 ) 
    cognates <<- c( cognates, cognates_once ) %>% unique() 
}

updateSynonyms <- function( page_html ) {
  page_html -> page_html
  synonyms_once <- page_html %>% html_nodes( xpath = synonyms_xpath ) %>% html_text()
  synonyms_once <- gsub( '.*[[:space:]].*', '#', synonyms_once )
  synonyms_once <- synonyms_once[ synonyms_once != c('#','') ] %>% unlist(use.names = FALSE)
  if( length( synonyms_once ) > 0 ) 
    synonyms <<- c( synonyms, synonyms_once) %>% unique() 
}

getDeclension <- function( page_html ) {
  page_html -> page_html
  form_class <- page_html %>% html_node( xpath = form_class_xpath ) %>% html_text()
  
  if( length( i <- grep( "przysłówek", form_class ) ) ) {
    form_word <<- "przysłówek"
    declension_df <- page_html %>% html_nodes( xpath = gradation_xpath  ) %>% html_text()
    if ( length( declension_df ) > 0 ) {
      declension_df %<>% extract(2:3) %>% removePunctuation() 
      declension_df <- gsub( '[[:space:]]', '', declension_df ) 
      declension_df %>% print()
      declension_df %>% return()
    }
    return(NULL)
  } else {
    declension_df <- page_html %>% html_node( xpath = declension_xpath ) 
    if ( length( declension_df ) > 0 ) {
      declension_df %<>% html_table( fill = TRUE )
      declension_df %<>% as.data.frame() %>% set_names( make.unique( names(.) ) ) 
    }
    if( length( i <- grep( "czasownik", form_class ) ) ) {
      if( length( i <- grep( "dk.", form_class ) ) 
          & !length(i <- grep( "dk. brak", form_class ) ) ){
        form_word <<- "czasownik"
        gsub( ".*dk\\. (.+?)\\).*", "\\1", form_class ) %>% getWords() %>% return()
      } else { 
        form_word <<- "czasownik"
        if ( length( declension_df ) > 0 ) {
          declension_df %<>% select( contains( "forma" ) | starts_with( "liczba" ) )
          declension_df %<>% filter( forma %in% conjugation_forms )  %>% return()
        }
      }
    } else if( length( i <- grep( "przymiotnik|rzeczownik", form_class[ 1 ] ) ) ){
      if( length( i <- grep( "przymiotnik", form_class ) ) )
        form_word <<- "przymiotnik"
      else form_word <<- "rzeczownik"
      if ( length( declension_df ) > 0 ) {
        declension_df %<>% select( contains( "przypadek" ) | starts_with( "liczba" ) )
        declension_df %<>% filter( przypadek %in% declension_forms )  %>% return()
      } else {
        form_word <<- 'brak odmiany' 
        return()
        }
      } 
  }
}

getWords <- function( word ) {
  word <- word
  url <- paste(wiki_href, word, sep = "")
  tryCatch(
      expr = {
        page_html <- url %>% read_html()
        Sys.sleep( 1.5 )
        updateSynonyms( page_html )
        updateCognates( page_html )
        return ( getDeclension( page_html ) )
      },
      error = function( e ) { 
        return( word )
        print( e )
      }
  )
}

retrieve <- function( word ) {
  tryCatch(
    expr = {
      print( word )
      declension <- word %>% getWords()
      if ( !form_word %in% c( 'przysłówek', 'brak odmiany' ) ) {
        declension %<>% select( starts_with( "liczba" ) )
        declension %<>% unlist( use.names = FALSE) %>% unique()
        #declension %<>% paste( collapse=',' ) 
        return( declension )
      } else return ( c( word, declension ) )
    },
    error = function( e ){ 
      return( word )
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

wordRegister <- NULL

for(row in 1:3){

  synonyms <<- NULL
  cognates <<- NULL
  NAWLrow <- NAWL[ row, ]
  
  declension <- NAWLrow$word %>% retrieve
  wordRegister <- c( wordRegister, NAWLrow$word )
  
  appendDeclension( row, declension, NAWLrow$category )
  
  if( is.null( synonyms ) & is.null( cognates )) {
    print('INFO - SYNONYMS SKIPPED')  
    next
  }
  
  for( i in 1:scrap_depth ){
    synonyms_2nd <- synonyms %>% unique
    synonyms <<- NULL
    cognates_2nd <- cognates %>% unique
    cognates <<- NULL
    
    if( length( synonyms_2nd ) > 0 )
      for( synonym in synonyms_2nd ) {
        if( !synonym %in% wordRegister & !is.na( synonym ) ) {
          declension <- retrieve( synonym ) 
          appendDeclension( row, declension, NAWLrow$category )
        }
      }
    wordRegister <- c( wordRegister, synonyms_2nd ) %>% unique
    
    if( length( cognates_2nd ) > 0 )
      for( cognate in cognates_2nd ) {
        if( !cognate %in% wordRegister &!is.na( cognate ) ) {
          declension <- retrieve( cognate ) 
          appendDeclension( row, declension, NAWLrow$category )
        }
      }
    wordRegister <- c( wordRegister, cognates_2nd ) %>% unique
  }
  
  #TO JSON:
  #df <- data.frame( id = NAWL$lp[ row ], declension = declension, score = NAWLrow$category )
  #df$declension <- df$declension %>% strsplit( ',' )
  #View(df)
  #nawlJSON <- rbind( nawlJSON, df )
}

#Save extended NAWL to JSON
#toJSON( nawlJSON, encoding = "UTF-8", pretty = TRUE) %>% write("nawl_extended_2.json" )


