source('setup.R')

#data import
NAWL <- read.csv( file="nawl_analysis.csv", header=TRUE, sep=";", fileEncoding="windows-1250")
nawlJSON <- data.frame( id=integer(), declension=factor(), score=factor() )
#target <- c('A', 'S','F', 'D')
#NAWL %<>% select(lp, word, category) %>% filter(category == target ) %>% print


updateSynonyms <- function( page_html ) {
  synonyms_once <- page_html %>% html_nodes( xpath = synonyms_xpath ) %>% html_text()
  synonyms_once <- gsub( '.*[[:space:]].*', '#', synonyms_once )
  synonyms_once <- synonyms_once[ synonyms_once != c('#','') ] %>% unlist(use.names = FALSE)
  #print( synonyms_once )
  if( !is.null( synonyms_once ) ) {
    synonyms <- c( synonyms, synonyms_once)
    print( synonyms_once )
  }
}

getDeclension <- function( page_html ) {
  form_class <- page_html %>% html_nodes( xpath = form_class_xpath ) %>% html_text()
  print(form_class)
  declension_df <- page_html %>% html_node( xpath = declension_xpath ) %>% html_table( fill = TRUE )
  declension_df %<>% as.data.frame() %>% set_names( make.unique( names(.) ) ) 
  if( length( i <- grep( "czasownik", form_class[ 1 ] ) ) ) {
    if( length(i <- grep( "dk.", form_class[1])) & !length(i <- grep( "dk. brak", form_class[1]))){
      gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1]) %>% getWords() %>% return()
    } else { 
      declension_df %<>% select( contains( "forma" ) | starts_with( "liczba" ) )
      declension_df %<>% filter( forma %in% conjugation_forms )  %>% return()
    }
  } else if(length(i <- grep("przymiotnik|rzeczownik", form_class[1]))){
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
        updateSynonyms( page_html )
        return ( getDeclension( page_html ) )
      },
      error = function( e ) { 
        print( e )
      },
      finally = {
        close(url)
      }
  )
}

retrieve <- function( word ) {
  #error_occured <- FALSE
  #skip_to_next <- FALSE
  tryCatch(
    expr = {
      declension <- word %>% getWords()
      declension %<>% select( starts_with( "liczba" ) )
      declension %<>% unlist( use.names = FALSE) %>% unique()
      declension %<>% paste( collapse=',' ) 
      return( declension )
      #print(declension)
    },
    error = function( e ){ 
      print( e )
      return( NULL )
    },
    warning = function( w ){
      print( w )
    },
    finally = {
      Sys.sleep( 1 )
    }
  )
}

#nrow( NAWL )
for(row in 1:3){
  
  #skip_to_next <- FALSE
  synonyms <- NULL
  NAWLrow <- NAWL[ row, ]
  print( NAWLrow$word )
  
  declension <- NAWLrow$word %>% retrieve
  print( declension )
  
  synonyms
  
  if( is.null( synonyms ) ) {
    print('SKIP !!!')  
      next
  }
  
  for( i in 1:scrap_depth ){
    synonyms_2nd <- synonyms
    synonyms <- NULL
    
   if( !is.null( synonyms_2nd ) ) {
      for( synonym in synonyms_2nd ) {
        #print( synonym )
        if( synonym != '' ){
          declension <- c( declension, retrieve( synonym ) )
          Sys.sleep( 1 )
        }
      }
    } else { break }
  }
  
  df<-data.frame( id = NAWL$lp[ row ], declension = declension, score = NAWLrow$category )
  df$declension <- df$declension %>% strsplit( ',' )
  print(df)
  nawlJSON <- rbind( nawlJSON, df )
}

#Save extended NAWL to JSON
toJSON( nawlJSON, encoding = "UTF-8", pretty = TRUE) %>% write("nawl_extended_2.json" )







# 
# 
# url <- paste( wiki_href, word, sep = "" )
# page_html <- url %>% read_html()
# 
# form_class <- page_html %>% html_nodes( xpath = form_class_xpath ) %>% html_text()
# 
# declension_df <- page_html %>% html_node( xpath = declension_xpath ) %>% html_table( fill = TRUE )
# declension_df %<>% as.data.frame() %>% set_names( make.unique( names(.) ) ) 
# 
# #przymiotnik|rzeczownik
# declension_df %<>% select( contains( "przypadek" ) | starts_with( "liczba" ) )
# declension_df %<>% filter( przypadek %in% declension_forms ) 
# 
# #czasownik
# declension_df %<>% select( contains( "forma" ) | starts_with( "liczba" ) )
# declension_df %<>% filter( forma %in% conjugation_forms )
# 
# #usuniecie duplikatów
# declension_df %<>% select( starts_with( "liczba" ) )
# declension_df %<>% unlist( use.names = FALSE) %>% unique()
# declension_df %<>% paste( collapse=',' ) 
# 
# 
# View ( declension_df )
# print( form_class )
# print( synonyms_once )
# 
# 
# 
# if( length(i <- grep("czasownik", form_class[1])) ){
#   if( length(i <- grep("dk.", form_class[1])) & !length(i <- grep("dk. brak", form_class[1]))){
#     gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1]) %>% getWords() %>% return()
#   } else { 
#     declension_df %>% filter(forma %in% conjugation_forms & !forma.1=="n") %>% return()
#   }
# } else if(length(i <- grep("przymiotnik|rzeczownik", form_class[1]))){
#   declension_df %>% filter(przypadek %in% declension_forms) %>% return()
# } 
# 
# 
# 


ret <- function( word ) {
    tryCatch(
    expr = {
      print('ret')
      return( word )
      #print(declension)
    },
    error = function( e ){ 
      print( e )
      #skip_to_next <<- TRUE
    },
    warning = function( w ){
    },
    finally = {
      Sys.sleep( 2 )
      print('ret2')
    }
  )
}



tryCatch(
  expr = {
    print('declension1')
    a <- ret('b')
    #stop("error message")
    print(a)
    print('declension2')
  },
  error = function( e ){ 
    print( e )
    
  },
  warning = function( w ){
  },
  finally = {
    print('declension3')
  }
)
