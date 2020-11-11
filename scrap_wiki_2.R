library(rvest)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(dplyr)

options(encoding = "UTF-8")
setwd('D://Projekty/R/wiki_scrapping_R/')

scrap_depth <- 3

NAWL <- read.csv( file="nawl_analysis.csv", header=TRUE, sep=";", fileEncoding="windows-1250")
nawlJSON <- data.frame( id=integer(), declension=factor(), score=factor() )

wiki_href <- 'https://pl.wiktionary.org/wiki/'
declension_xpath <- '//*[@id="mw-content-text"]/div[1]//dl[./dt/span[contains(.,"odmiana:")]]/dd//table'
form_class_xpath <- '//*[@id="mw-content-text"]/div[1]//dl[./dt/span[contains(.,"znaczenie:")]]/dd//p'
synonyms_xpath <- "//*[@id='mw-content-text']/div[1]//dl[./dt/span[contains(.,'synonimy:')]]/dd/a"

conjugation_forms <- c("bezokolicznik", "czas przyszły prosty","czas przeszły")
declension_forms <- c("mianownik", "dopełniacz", "celownik","biernik","narzędnik","miejscownik","wołacz")

#/html/body/div[3]/div[3]/div[5]/div[1]/dl[8]/dd

synonyms <- ''
synonyms_2nd <- ''

getWords <- function( word ) {
  
  error_occured <- FALSE
  word <- word
  url <- paste(wiki_href, word, sep = "")

  tryCatch(
      expr = {
        page_html <- url %>% read_html()
        form_class <- page_html %>% html_nodes(xpath=form_class_xpath) %>% html_text()
        print(form_class)
      },
      error = function( e ) { 
        error_occured <- TRUE
      }
    )
  
  if( !error_occured ){
    
    declension_df <- page_html %>% html_nodes(xpath=declension_xpath) %>% html_table(fill = TRUE) %>% as.data.frame()
   
    synonyms_once <- page_html %>% html_nodes( xpath = synonyms_xpath ) %>% html_text()
    synonyms_once <- gsub( '.*[[:space:]].*', '#', synonyms_once )
    synonyms_once <- synonyms_once[ synonyms_once != c('#','') ] %>% unlist(use.names = FALSE)
    
    print(synonyms_once)
    
    synonyms <- c( synonyms, synonyms_once)
    
    if( length(i <- grep("czasownik", form_class[1])) ){
      if( length(i <- grep("dk.", form_class[1])) & !length(i <- grep("dk. brak", form_class[1]))){
        gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1]) %>% getWords() %>% return()
      } else { 
        declension_df %>% filter(forma %in% conjugation_forms & !forma.1=="n") %>% return()
      }
    } else if(length(i <- grep("przymiotnik|rzeczownik", form_class[1]))){
      declension_df %>% filter(przypadek %in% declension_forms) %>% return()
    } 
  }
  
  #
}
  
  

#nrow(NAWL)
#739
#target <- c('A', 'S','F', 'D')
#NAWL %<>% select(lp, word, category) %>% filter(category == target ) %>% print
#NAWL

skip_to_next <- FALSE

retrieve <- function( word ) {
  skip_to_next <- FALSE
  tryCatch(
    expr = {
      declension <- word %>% getWords() %>% select( starts_with( "liczba" ) ) 
      declension <- declension %>% unlist(use.names = FALSE) %>% unique() %>% paste( collapse=',' )
    },
    error = function( e ){ 
      print( e )
      skip_to_next <<- TRUE
    },
    warning = function( w ){
    },
    finally = {
      Sys.sleep( 1 )
    }
  )
  if( !skip_to_next ) { return( declension ) }
}

#nrow( NAWL )

for(row in 1:3){
  
  #skip_to_next <- FALSE
  synonyms <- ''
  synonyms_2nd <- ''
  declension <- ''
  NAWLrow <- NAWL[ row, ]
  print( NAWLrow$word )
  
  declension <- NAWLrow$word %>% retrieve
  
  if( skip_to_next ) { 
    print('SKIP !!!')  
      next
  }
  
  for( i in 1:scrap_depth ){
    
    synonyms_2nd <- synonyms
    synonyms <- ''
    
    for( synonym in synonyms_2nd ) {
      #print( synonym )
      if( synonym != '' ){
        declension <- c( declension, retrieve( synonym ) )
        Sys.sleep( 1 )
      }
    }
  }

  df<-data.frame(id=NAWL$lp[row], declension=declension, score=NAWLrow$category)
  df$declension <- df$declension %>% strsplit(',')
  
  print(df)
  
  nawlJSON <- rbind(nawlJSON, df)
  
}

toJSON(nawlJSON, encoding = "UTF-8", pretty = TRUE) %>% write("nawl_extended_2.json")





# 
# getWords('znamienity')
# getWords('znakomity')
# 
# 
# word <- 'znamienity'
# word <- 'znakomity'
# 
# words <- c('znamienity', 'znakomity', 'równowaga')
# 
# for( word in words ){
#   skip_to_next <- FALSE
#   tryCatch(
#     expr = {
#      print(word)
#      print(getWords(word)) 
#     },
#     error = function( e ) { 
#       print(e)
#       skip_to_next <<- TRUE}
#   )
#   Sys.sleep( 2 )
#   if( skip_to_next ) {
#     
#     next
#   }
# }
# //div[@class="lang-pl fldt-synonimy"]
# 
# ss <- '//*[@id="mw-content-text"]'
# ss <- '//*[@id="mw-content-text"]/div[1]/dl/dd/a'
# word <- 'super'
# url <- paste(wiki_href, word, sep = "")
# url
# page_html <- url %>% read_html()
# synonyms_df <- page_html %>% html_nodes(xpath=ss) 
# 
# %>% html_nodes(".lang-pl.fldt-synonimy")
#   html_nodes(xpath=synonyms_xpath) 
  
# synonyms_df
# 
# ss <- '//dd[@class="fldt-synonimy"]'

# word <- 'świetny'
# word <- 'super'
# word <- 'świetny'
# url <- paste( wiki_href, word, sep = "" )
# page_html <- url %>% read_html()
# synonyms_once <- page_html %>% html_nodes( xpath = synonyms_xpath ) %>% html_text()
# synonyms_once <- gsub( '.*[[:space:]].*', '#', synonyms_once )
# synonyms_once <- synonyms_once[ synonyms_once != '#' ] %>% unlist(use.names = FALSE)
# synonyms_once 

# w <- c('a as', 'ba', 'bq b by', 'cde')
# w <- gsub('.*[[:space:]].*', '#', w)
# w <- w[w!='#']
# w
# 
# w<-w['#'] <- NULL
# View(w)

# 
# 
# 
# 
# %>% html_nodes(css='a') 
# synonyms_df %>% as.data.frame() %>% write.table(file="TestData2.txt", quote=F, sep=";")
# 
# 
# 
# %>% html_nodes(css='[class=.lang-pl.fldt-synonimy]')
# 
# 
# synonyms_df <- synonyms_df %>%  html_nodes(xpath="//*span[contains(., 'synonimy:')")
# warnings()
# synonyms_df
# 
# synonyms_df <- page_html %>% html_nodes(xpath=ss) 
# synonyms_df
# 
# 
# sink("outfile.txt")
# print(synonyms_df)
# sink()
# 
# write_xml(synonyms_df, file="temp.html")
# 
# 
# cat(synonyms_df,file="outfile.txt",sep="\n")
# 
# fileConn<-file("output.txt")
# writeLines(c("Hello","World"), fileConn)
# close(fileConn)
# 
# #writeLines(as.vector(synonyms_df), "outfile.txt")
# 
# 
# 
# //div[contains(., 'Kod umowy:')

# i<-1
# rapapa <- c('a','b')
# 
# 
# salamalejkum <- function( word ) {
# 
#   while( 1 ) {
#     
#     #print( i )
#     rapapa <- c( rapapa, i )
#     print( rapapa )
#     rapapa <- rapapa[ rapapa != rapapa[i] ]
#     i <- i + 1
#     Sys.sleep( 2 )
#     if(rapapa %>% length() <= 0){
#       break
#     }
#   }
#   
#   for(rap in rapapa){
#     i<-i+1
#     print(rap,i)
#     rapapa <- c(rapapa, i)
#   }
#   
# }



wiki_href <- 'https://pl.wiktionary.org/wiki/'
declension_xpath <- '//*[@id="mw-content-text"]/div[1]//dl[./dt/span[contains(.,"odmiana:")]]/dd//table'
form_class_xpath <- '//*[@id="mw-content-text"]/div[@class="mw-parser-output"]/p[1]/i'

conjugation_forms <- c("bezokolicznik", "czas przyszły prosty","czas przeszły")
declension_forms <- c("mianownik", "dopełniacz", "celownik","biernik","narzędnik","miejscownik","wołacz")

word <- 'świetny'

url <- paste( wiki_href, word, sep = "" )
page_html <- url %>% read_html()
synonyms_once <- page_html %>% html_node( xpath = declension_xpath )
form_class <- page_html %>% html_nodes( xpath = form_class_xpath ) %>% html_text()
print( form_class )
print( synonyms_once )

declension_df <- synonyms_once  %>% html_table( fill = TRUE ) %>% as.data.frame()  
declension_df %<>% set_names( make.unique( names(.) ) ) 
declension_df %<>% select( contains( "przypadek" ) | starts_with( "liczba" ) )
declension_df %<>% filter( przypadek %in% declension_forms ) %>% select( starts_with( "liczba" ) )
declension_df %<>% unlist( use.names = FALSE) %>% unique()
declension_df %<>% paste( collapse=',' ) 
View ( declension_df )







# for ( node in synonyms_once ){
#   declension_df <- node %>% html_table(fill = TRUE) %>% as.data.frame()
#   # if( length( i <- grep( "przymiotnik|rzeczownik", form_class[1] ) ) ) {
#   #   declension_df %<>% filter( przypadek %in% declension_forms )
#   # }
#   # declension_df %<>% select( starts_with( "liczba" ) ) 
#   # declension_df %<>% unlist( use.names = FALSE) %>% unique() %>% paste( collapse=',' ) 
#   View( declension_df )
# }



# 
# declension <- declension %>% 
# 
# 
#   if( length(i <- grep("czasownik", form_class[1])) ){
#     if( length(i <- grep("dk.", form_class[1])) & !length(i <- grep("dk. brak", form_class[1]))){
#       gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1]) %>% getWords() %>% return()
#     } else { 
#       declension_df %>% filter(forma %in% conjugation_forms & !forma.1=="n") %>% return()
#     }
#   } else if(length(i <- grep("przymiotnik|rzeczownik", form_class[1]))){
#     declension_df %>% filter(przypadek %in% declension_forms) %>% return()
#   } 
#   
#   
#   
#   
# 
# nrow(synonyms_once)
# declension_df <- page_html %>% html_nodes( xpath = declension_xpath ) %>% html_table(fill = TRUE) %>% as.data.frame()
# declension_df
# 
# synonyms_once 
# synonyms_once <- page_html %>% html_nodes( xpath = form_class_xpath ) 
# synonyms_once 
# 
# synonyms_once <- gsub( '.*[[:space:]].*', '#', synonyms_once )
# synonyms_once <- synonyms_once[ synonyms_once != '#' ] %>% unlist(use.names = FALSE)
# synonyms_once 

