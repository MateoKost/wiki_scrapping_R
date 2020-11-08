library(rvest)
library(dplyr)
library(jsonlite)
library(stringr)
library(tidyverse)
options(encoding = "UTF-8")
setwd('D://Projekty/R/Praca inż/')

NAWL <- read.csv(file="nawl_analysis.csv", header=TRUE, sep=";",fileEncoding="windows-1250")


getWords <- function(word){
  word <- word
  wiki_href <- 'https://pl.wiktionary.org/wiki/'
  declension_xpath <- '//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table'
  href_word <- paste(wiki_href, word, sep = "")
  
  page_html <- read_html(href_word)
  form_class <- page_html %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/p') %>% html_text()
 
  if(length(i <- grep("czasownik", form_class[1]))){
    if(length(i <- grep("dk.", form_class[1])) & !length(i <- grep("dk. brak", form_class[1]))){
      new_word <- gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1])
      href_word  <- paste(wiki_href, new_word, sep = "")
      page_html  <- read_html(href_word)
      form_class <- page_html %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/p') %>% html_text()
    }
    conjugation  <- page_html %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
    conjugation <- as.data.frame(conjugation)
    return(unique(unlist(conjugation[2:5,3:8], use.names = FALSE)))
  } else if(length(i <- grep("przymiotnik", form_class[1]))){
    declension  <- page_html %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
    declension  <- as.data.frame(declension)
    return(unique(unlist(declension[2:8,2:7], use.names = FALSE)))
  } else if(length(i <- grep("rzeczownik", form_class[1]))){
    declension  <- page_html %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
    declension  <- as.data.frame(declension)
    return(unique(unlist(declension[1:7,2:3], use.names = FALSE)))
  }
}

nawlJSON <- data.frame(id=integer(),declension=factor())

for(row in 2899:nrow(NAWL)){
  print(MyData$word[row])
  df<-data.frame(id=MyData$lp[row],declension=paste(getWords(NAWL$word[row]), collapse=','))
  df$declension <- strsplit(df$declension, ',')
  nawlJSON <- rbind(recordJSON, df)
  Sys.sleep(1)
}

write(toJSON(recordJSON, encoding = "UTF-8", pretty = TRUE), "nawl_extended.json")


word <- 'ufać'
href <- 'https://pl.wiktionary.org/wiki/'
href_single <- paste(href, word, sep = "")

page_single <- read_html(href_single)
View(page_single)
form_class <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/p') %>% html_text()


if(length(i <- grep("czasownik", form_class[1]))){
  if(length(i <- grep("dk.", form_class[1])) & !length(i <- grep("dk. brak", form_class[1]))){
    new_word <- gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1])
    href_single <- paste(href, new_word, sep = "")
    page_single <- read_html(href_single)
    form_class <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/p') %>% html_text()
    #View(form_class)
  }
  single_declension  <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
  single_declension <- as.data.frame(single_declension)
  View(single_declension)
  simplified_conjugation <- unique(unlist(single_declension[2:5,3:8], use.names = FALSE))
  record <- data.frame(id=1,simplified_conjugation=paste( simplified_conjugation, collapse=','))
  record$simplified_conjugation <- strsplit(record$simplified_conjugation, ',')
  View(record)
  write(toJSON(record, encoding = "UTF-8", pretty = TRUE), "words123.json")
} else if(length(i <- grep("przymiotnik", form_class[1]))){
  single_declension  <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
  single_declension <- as.data.frame(single_declension)
  simplified_conjugation <- unique(unlist(single_declension[2:8,2:7], use.names = FALSE))
  View(simplified_conjugation)
} else if(length(i <- grep("rzeczownik", form_class[1]))){
  declension  <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
  declension <- as.data.frame(declension)
  simplified_declension <- unique(unlist(declension[1:7,2:3], use.names = FALSE))
  View(simplified_declension)
  record <- data.frame(id=1,simplified_declension=paste( simplified_declension, collapse=','))
  record$simplified_declension <- strsplit(record$simplified_declension, ',')
  View(record)
  #simplified_conjugation <- unique(unlist(single_declension[2:8,2:7], use.names = FALSE))
  #View(simplified_conjugation)
}

