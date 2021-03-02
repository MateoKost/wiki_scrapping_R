source('setup.R')
source('methods.R')

#data import
NAWL <- read.csv( file="hatred_speech_words.csv", header=TRUE, sep=";", 
                  fileEncoding ="windows-1250")
nawlJSON <- data.frame( id = integer(), declension = factor(), score = factor() )

#main program
for( row in begin_at:nrow( NAWL ) ){
  sprintf( '---begin-of-row-%s---', row ) %>% print
  NAWLrow <- NAWL[ row, ]
  resetResemblingWords()
  wordParams <- c( row, 0, 'B', 0 , NAWLrow$category )
  names( wordParams ) <- c( 'rId', 'deph', 'typ', 'tpId', 'cat')
    
  wordRegister <- c( wordRegister, NAWLrow$word )
  appendWord( wordParams, NAWLrow$word, 'R' 
              )
  
  declension <- NAWLrow$word %>% retrieve
  appendWord( wordParams, declension, 'D' )
  
  if( is.null( synonyms ) & is.null( cognates )) { next }
 
  for( deph in 1:scrap_depth ){
    sprintf( "---deph-%s---", deph ) %>% print
    synonyms_2nd <- synonyms %>% unique
    cognates_2nd <- cognates %>% unique
    resetResemblingWords()
    
    wordParams[ 'deph' ] <- deph
    wordParams[ 'typ' ] <- 'S'
    handleResemblingWords( wordParams, synonyms_2nd )
    
    wordParams[ 'typ' ] <- 'C'
    handleResemblingWords( wordParams, cognates_2nd )
  }
  sprintf( '---end-of-row-%s---', row ) %>% print
}




