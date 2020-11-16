source('setup.R')
source('methods.R')

#data import
NAWL <- read.csv( file="hatred_speech_words.csv", header=TRUE, sep=";", fileEncoding="windows-1250")
#NAWL <- read.csv( file="nawl_analysis.csv", header=TRUE, sep=";", fileEncoding="windows-1250")
nawlJSON <- data.frame( id = integer(), declension = factor(), score = factor() )
#target_categories <- c('A', 'S','F', 'D')
#NAWL %<>% select(lp, word, category) %>% filter( category == target_categories )

for( row in begin_at:nrow( NAWL ) ){

  resetResemblingWords()
  NAWLrow <- NAWL[ row, ]
  
  sprintf( '---begin-of-row-%s---', row ) %>% print()

  wordRegister <- c( wordRegister, NAWLrow$word )
  appendRegister( row, deph, 'B', 0, word, NAWLrow$category)
  
  declension <- NAWLrow$word %>% retrieve
  appendDeclension( row, declension )
  
  if( is.null( synonyms ) & is.null( cognates )) { next }
 
  for( deph in 1:scrap_depth ){
    
    sprintf( "---deph-%s---", i ) %>% print()
    
    synonyms_2nd <- synonyms %>% unique
    cognates_2nd <- cognates %>% unique
    resetResemblingWords()
    
    handleResemblingWords( row, deph, 'S', synonyms_2nd )
    handleResemblingWords( row, deph, 'C', cognates_2nd )
  }
  
  sprintf( '---end-of-row-%s---', row ) %>% print()
  
  #TO JSON:
  #df <- data.frame( id = NAWL$lp[ row ], declension = declension, score = NAWLrow$category )
  #df$declension <- df$declension %>% strsplit( ',' )
  #View(df)
  #nawlJSON <- rbind( nawlJSON, df )
}

#Save extended NAWL to JSON
#toJSON( nawlJSON, encoding = "UTF-8", pretty = TRUE) %>% write("nawl_extended_2.json" )
