#setup
library(rvest)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(tm)

#options
options(encoding = "UTF-8")
setwd('D://Projekty/R/wiki_scrapping_R/')

#scrapp settings
scrap_depth <- 2
wiki_href <- 'https://pl.wiktionary.org/wiki/'
content_xpath <- '//*[@id="mw-content-text"]/div[@class="mw-parser-output"]'
declension_xpath <- paste0( content_xpath, '//dl[./dt/span[contains(.,"odmiana:")]]/dd//table' )
gradation_xpath  <- paste0( content_xpath, '//dl[./dt/span[contains(.,"odmiana:")]]/dd/text()' )
form_class_xpath <- paste0( content_xpath, '/p[1]/i' )
synonyms_xpath   <- paste0( content_xpath, "//dl[./dt/span[contains(.,'synonimy:')]]/dd/a" )
cognate_xpath    <- paste0( content_xpath, "//dl[./dt/span[contains(.,'wyrazy pokrewne:')]]/dd/a" )
conjugation_forms <- c("bezokolicznik", "czas przyszły prosty","czas przeszły")
declension_forms <- c("mianownik", "dopełniacz", "celownik","biernik","narzędnik","miejscownik","wołacz")

#logic settings
begin_at <- 1
synonyms <- NULL
synonyms_2nd <- NULL
cognates <- NULL
form_word <- ''
wordRegister <- NULL

# declension_xpath <- '//*[@id="mw-content-text"]/div[1]//dl[./dt/span[contains(.,"odmiana:")]]/dd//table'
# gradation_xpath <- '//*[@id="mw-content-text"]/div[1]//dl[./dt/span[contains(.,"odmiana:")]]/dd/text()'
# form_class_xpath <- '//*[@id="mw-content-text"]/div[@class="mw-parser-output"]/p[1]/i'
# synonyms_xpath <- "//*[@id='mw-content-text']/div[1]//dl[./dt/span[contains(.,'synonimy:')]]/dd/a"
# cognate_xpath <- "//*[@id='mw-content-text']/div[1]//dl[./dt/span[contains(.,'wyrazy pokrewne:')]]/dd/a"

