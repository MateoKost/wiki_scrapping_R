#setup
library(rvest)
library(jsonlite)
library(tidyverse)
library(magrittr)
library(tm)
library(reshape2)


#options
options(encoding = "UTF-8")
setwd('D://Projekty/R/wiki_scrapping_R/Cleanese')

`%nin%` <- function (x, table) is.na(match(x, table, nomatch=NA_integer_))

declension_hatred <- read.csv( file="declension_hatred.csv", header=TRUE, sep=";", 
                  fileEncoding ="windows-1250") %>% as.data.frame()

declension_hatred %<>% mutate( kir=paste(id, deph, type, type_id,sep='_') )


register_hatred_wrong <- read.csv( file="register_hatred_wrong.csv", header=TRUE,
                                   sep=";", fileEncoding ="windows-1250") %>% as.data.frame()

register_hatred_wrong %<>% select( id, deph, type, type_id ) %>%
        mutate( kir=paste(id, deph, type, type_id,sep='_') )

declension_hatred_cleaned <- declension_hatred %>% 
        filter( kir %nin% register_hatred_wrong$kir ) %>% select( -kir )


declension_hatred_cleaned$word <- gsub( '[[:space:]]+|\\[[0-9]\\]|\\.mw.*}}|najbardziej|bardziej', '', declension_hatred_cleaned$word  )
declension_hatred_cleaned$word <- gsub( 'Ĺş', 'ź', declension_hatred_cleaned$word  )

declension_hatred_cleaned %<>% cbind(colsplit(declension_hatred_cleaned$word, "/", c("left", "right")))
declension_hatred_cleaned$right <- gsub( '.*[\\./].*', '', declension_hatred_cleaned$right  )
head(declension_hatred_cleaned,10)

additon_word <- declension_hatred_cleaned %>% filter( right!='') %>% select( -c('word','left') ) 
additon_word %<>% unique() %>% rename( word=right )
declension_hatred_cleaned$word <- declension_hatred_cleaned$left

declension_hatred_cleaned %<>% select( -c('left','right') )  %>% rbind( additon_word ) %>% 
        arrange( id, deph, type, type_id, word )
head(adeclension_hatred_cleaned,10)

write.table( declension_hatred_cleaned, file = "./declension_hatred_cleaned.csv", 
             append = F, sep = ';', row.names = F, 
             col.names = T, fileEncoding = "windows-1250" )

