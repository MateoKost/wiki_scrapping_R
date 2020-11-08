#install.packages("rvest")
#install.packages("dplyr")
library(rvest)
library(dplyr)
library(jsonlite)
library(stringr)
library(tidyverse)

options(encoding = "UTF-8")
word <- 'kupa'
href <- 'http://aztekium.pl/find.py?lang=pl&q='
href_single <- paste(href, word, sep = "")

page_single <- read_html(href_single)
name_single <- page %>% html_nodes("font") %>% html_text()
single_declension <- c(name_single[2], name_single[4], name_single[6],name_single[8], name_single[10], name_single[12], name_single[13])

href_plural <- page %>% html_nodes("td td td a") %>% html_attr("href")
href_plural <- href_plural[2] %>% paste('http://aztekium.pl/find.py', .,sep = "")
page_plural <- read_html(href_plural)
name_plural <- page_plural %>% html_nodes("font") %>% html_text()
plural_declension <- c(name_plural[2], name_plural[4], name_plural[6], name_plural[8], name_plural[10], name_plural[12], name_plural[13])

record <- data.frame(id=1,single_declension=paste( unlist(single_declension), collapse=','),plural_declension=paste( unlist(plural_declension), collapse=','))
record$single_declension <- strsplit(record$single_declension, ',')
record$plural_declension <- strsplit(record$plural_declension, ',')
View(record)
#write(toJSON(list('words'=record), encoding = "UTF-8", pretty = TRUE), "con.json")

#toJSON(record, encoding = "UTF-8", pretty = TRUE)
#write(record, "words2.json")
write(toJSON(record, encoding = "UTF-8", pretty = TRUE), "words12.json")

#single_declension <- c(name[2], name[4], name[6], name[8], name[10], name[12], name[13])

#setwd("D://Projekty/R/Praca inż")
#getwd()

#fileConn<-file("output.txt")
#writeLines(c("Hello","World"), fileConn)
#close(fileConn)

setwd("D://Projekty/R/Praca inż")
getwd()

word <- 'nagradzać'
href <- 'https://pl.wiktionary.org/wiki/'
href_single <- paste(href, word, sep = "")

page_single <- read_html(href_single)
View(page_single)
form_class <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/p') %>% html_text()

if(length(i <- grep("czasownik", form_class[1]))){
  if(length(i <- grep("dk.", form_class[1]))){
    #new_word <- str_split(form_class[1], "dk.", simplify = TRUE)
    #View(new_word[,2])
    new_word <- gsub(".*dk\\. (.+?)\\).*", "\\1", form_class[1])
    href_single <- paste(href, new_word, sep = "")
    page_single <- read_html(href_single)
    form_class <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/p') %>% html_text()
    #View(form_class)
  }
  single_declension  <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
  single_declension <- as.data.frame(single_declension)
  simplified_conjugation <- unique(unlist(single_declension[2:5,3:8], use.names = FALSE))
  record <- data.frame(id=1,simplified_conjugation=paste( simplified_conjugation, collapse=','))
  record$simplified_conjugation <- strsplit(record$simplified_conjugation, ',')
  View(record)
  write(toJSON(record, encoding = "UTF-8", pretty = TRUE), "words123.json")
} else {
  #form_class<-str_split(form_class[1], "[, ]", simplify = TRUE)
  #View(form_class[,1])
  single_declension  <- page_single %>% html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/dl[4]/dd/div/div[2]/table') %>% html_table(fill = TRUE)
  single_declension <- as.data.frame(single_declension)
  View(single_declension)
}

#single_declension <- c(name_single[2], name_single[4], name_single[6],name_single[8], name_single[10], name_single[12], name_single[13])





href_plural <- page %>% html_nodes("td td td a") %>% html_attr("href")
href_plural <- href_plural[2] %>% paste('http://aztekium.pl/find.py', .,sep = "")
page_plural <- read_html(href_plural)
name_plural <- page_plural %>% html_nodes("font") %>% html_text()
plural_declension <- c(name_plural[2], name_plural[4], name_plural[6], name_plural[8], name_plural[10], name_plural[12], name_plural[13])

record <- data.frame(id=1,single_declension=paste( unlist(single_declension), collapse=','),plural_declension=paste( unlist(plural_declension), collapse=','))
record$single_declension <- strsplit(record$single_declension, ',')
record$plural_declension <- strsplit(record$plural_declension, ',')
View(record)
#write(toJSON(list('words'=record), encoding = "UTF-8", pretty = TRUE), "con.json")

#toJSON(record, encoding = "UTF-8", pretty = TRUE)
#write(record, "words2.json")
write(toJSON(record, encoding = "UTF-8", pretty = TRUE), "words12.json")



r<-4
class(r)


x <- c(1,3, 5)
y <- c(3, 2, 10)
rbind(x,y)

x <- c(4, TRUE)
class(x)

x <- list(2, "a", "b", TRUE)
a<-x[[1]] 
class(a)
print(a)

x <- 1:4
y <- 2:3
a<-x+y
class(a)


x <- c(3, 5, 1, 10, 12, 6)
x[x<6]<-0
x



