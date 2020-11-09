library(rvest)
library(jsonlite)
library(tidyverse)
options(encoding = "UTF-8")
setwd('D://Projekty/R/wiki_scrapping_R/')

NAWL <- read.csv( file="nawl_analysis.csv", header=TRUE, sep=";", fileEncoding="windows-1250")
nawlJSON <- data.frame( id=integer(), declension=factor(), score=factor() )

wiki_href <- 'https://pl.wiktionary.org/wiki/'
declension_xpath <- '//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table'
form_class_xpath <- '//*[@id="mw-content-text"]/div[1]/p'
synonyms_xpath <- '//dd[@class="lang-pl fldt-synonimy"]'
#synonyms_xpath <- '//*[@id="mw-content-text"]/div[1]/dl[8]/dd/a'
##mw-content-text > div.mw-parser-output > dl:nth-child(10) > dd

conjugation_forms <- c("bezokolicznik", "czas przyszły prosty","czas przeszły")
declension_forms <- c("mianownik", "dopełniacz", "celownik","biernik","narzędnik","miejscownik","wołacz")

#/html/body/div[3]/div[3]/div[5]/div[1]/dl[8]/dd

synonyms <- ''

getWords <- function( word ) {
  
  error_occured <- FALSE
  word <- word
  url <- paste(wiki_href, word, sep = "")

  
  tryCatch(
      expr = {
        page_html <- url %>% read_html()
        form_class <- page_html %>% html_nodes(xpath=form_class_xpath) %>% html_text()
      },
      error = function( e ) { 
        error_occured <- TRUE
      }
    )
  
  
  if( !error_occured ){
    
    declension_df <- page_html %>% html_nodes(xpath=declension_xpath) %>% html_table(fill = TRUE) %>% as.data.frame()
    synonyms_df <- page_html %>% html_nodes(xpath=synonyms_xpath) %>% html_table(fill = TRUE) %>% as.data.frame()
    
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
  
  close(url)
}
  
  

#nrow(NAWL)
#739
target <- c('A', 'S','F', 'D')
NAWL %<>% select(lp, word, category) %>% filter(category == target ) %>% print
NAWL

for(row in 1:nrow(NAWL)){
  skip_to_next <- FALSE
  synonyms <- ''
  NAWLrow <- NAWL[row,]
  print(NAWLrow$word)
  
  tryCatch(
    expr = {
      declension <- NAWLrow$word %>% getWords() %>% select(starts_with("liczba")) %>% unlist(use.names = FALSE) %>% unique() %>% paste(collapse=',')
    },
    error = function(e){ 
      print(e)
      skip_to_next <<- TRUE
    },
    warning = function(w){
    },
    finally = {
      Sys.sleep( 1 )
    }
  )
  if( skip_to_next ) { next }
  df<-data.frame(id=NAWL$lp[row], declension=declension, score=NAWLrow$category)
  df$declension <- df$declension %>% strsplit(',')
  nawlJSON <- rbind(nawlJSON, df)
  
}

toJSON(nawlJSON, encoding = "UTF-8", pretty = TRUE) %>% write("nawl_extended_2.json")






getWords('znamienity')
getWords('znakomity')


word <- 'znamienity'
word <- 'znakomity'

words <- c('znamienity', 'znakomity', 'równowaga')

for( word in words ){
  skip_to_next <- FALSE
  tryCatch(
    expr = {
     print(word)
     print(getWords(word)) 
    },
    error = function( e ) { 
      print(e)
      skip_to_next <<- TRUE}
  )
  Sys.sleep( 2 )
  if( skip_to_next ) {next}
}
//div[@class="lang-pl fldt-synonimy"]

ss <- '//*[@id="mw-content-text"]'
ss <- '//*[@id="mw-content-text"]/div[1]/dl/dd/a'
word <- 'super'
url <- paste(wiki_href, word, sep = "")
url
page_html <- url %>% read_html()
synonyms_df <- page_html %>% html_nodes(xpath=ss) 

%>% html_nodes(".lang-pl.fldt-synonimy")
  html_nodes(xpath=synonyms_xpath) 
  
synonyms_df

ss <- '//dd[@class="fldt-synonimy"]'

ss <- '//*[@id="mw-content-text"]/div[1]'
word <- 'świetny'
word <- 'super'
word <- 'świetny'
url <- paste(wiki_href, word, sep = "")
page_html <- url %>% read_html()
synonyms <- page_html %>% html_nodes(xpath=ss) %>% html_nodes(xpath="//dl[./dt/span[contains(.,'synonimy:')]]/dd/a") %>% html_text()
synonyms <- gsub('.*[[:space:]].*', '#', synonyms)
synonyms <- synonyms[ synonyms != '#' ]
synonyms

w <- c('a as', 'ba', 'bq b by', 'cde')
w <- gsub('.*[[:space:]].*', '#', w)
w <- w[w!='#']
w

w<-w['#'] <- NULL
View(w)

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



