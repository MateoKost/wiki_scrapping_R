#setup
library(rvest)
library(jsonlite)
library(tidyverse)
library(magrittr)
options(encoding = "UTF-8")
setwd('D://Projekty/R/wiki_scrapping_R/')

#scrapp settings
scrap_depth <- 3
wiki_href <- 'https://pl.wiktionary.org/wiki/'
declension_xpath <- '//*[@id="mw-content-text"]/div[1]//dl[./dt/span[contains(.,"odmiana:")]]/dd//table'
form_class_xpath <- '//*[@id="mw-content-text"]/div[@class="mw-parser-output"]/p[1]/i'
synonyms_xpath <- "//*[@id='mw-content-text']/div[1]//dl[./dt/span[contains(.,'synonimy:')]]/dd/a"
conjugation_forms <- c("bezokolicznik", "czas przyszły prosty","czas przeszły")
declension_forms <- c("mianownik", "dopełniacz", "celownik","biernik","narzędnik","miejscownik","wołacz")

#logic settings
synonyms <- NULL
synonyms_2nd <- NULL
skip_to_next <- FALSE