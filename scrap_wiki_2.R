library(rvest)
library(jsonlite)
library(tidyverse)
options(encoding = "UTF-8")
setwd('D://Projekty/R/Scrapping/')

NAWL <- read.csv(file="nawl_analysis.csv", header=TRUE, sep=";", fileEncoding="windows-1250")

wiki_href <- 'https://pl.wiktionary.org/wiki/'
declension_xpath <- '//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table'
form_class_xpath <- '//*[@id="mw-content-text"]/div[1]/p'
synonyms_xpath <- '//*[contains(concat( " ", @class, " " ), concat( " ", "fldt-synonimy", " " ))]'
conjugation_forms <- c("bezokolicznik", "czas przyszły prosty","czas przeszły")
declension_forms <- c("mianownik", "dopełniacz", "celownik","biernik","narzędnik","miejscownik","wołacz")

nawlJSON <- data.frame(id=integer(),declension=factor(),score=factor())

synonyms <- ''

getWords <- function(word){
  word <- word
  page_html <- paste(wiki_href, word, sep = "") %>% read_html()
  declension_df <- page_html %>% html_nodes(xpath=declension_xpath) %>% html_table(fill = TRUE) %>% as.data.frame()
  form_class <- page_html %>% html_nodes(xpath=form_class_xpath) %>% html_text()
  
  if(length(i <- grep("czasownik", form_class[1]))){
    if(length(i <- grep("dk.", form_class[1])) & !length(i <- grep("dk. brak", form_class[1]))){
      gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1]) %>% getWords() %>% return()
    } else { 
      declension_df %>% filter(forma %in% conjugation_forms & !forma.1=="n") %>% return()
    }
  } else if(length(i <- grep("przymiotnik|rzeczownik", form_class[1]))){
    declension_df %>% filter(przypadek %in% declension_forms) %>% return()
  } 
}
#nrow(NAWL)
for(row in 1:739){
  synonyms <- ''
  NAWLrow <- NAWL[row,]
  print(NAWLrow$word)
  declension <- NAWLrow$word %>% getWords() %>% select(starts_with("liczba")) %>% unlist(use.names = FALSE) %>% unique() %>% paste(collapse=',')

  df<-data.frame(id=NAWL$lp[row], declension=declension, score=NAWLrow$category)
  df$declension <- df$declension %>% strsplit(',')
  nawlJSON <- rbind(nawlJSON, df)
  Sys.sleep(1)
}

toJSON(nawlJSON, encoding = "UTF-8", pretty = TRUE) %>% write("nawl_extended_2.json")


tryCatch(
        expr = {
                getWords(word)
        },
        error = function(e){ 
                print('abcd')
        },
        warning = function(w){
                # (Optional)
                # Do this if an warning is caught...
        },
        finally = {
                print('a')
        }
)



getWords('znamienity')
getWords('znakomity')


word <- 'znamienity'
word <- 'znakomity'



