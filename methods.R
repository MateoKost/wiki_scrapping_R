updateCognates <- function( page_html ) {
        page_html -> page_html
        cognates_once <- page_html %>% html_nodes( xpath = cognate_xpath ) %>% html_text()
        cognates_once <- gsub( ' się', '', cognates_once ) %>% unlist( use.names = FALSE )
        if( length( cognates_once ) > 0 ) 
                cognates <<- c( cognates, cognates_once ) %>% unique() 
}

updateSynonyms <- function( page_html ) {
        page_html -> page_html
        synonyms_once <- page_html %>% html_nodes( xpath = synonyms_xpath ) %>% html_text()
        synonyms_once <- gsub( '.*[[:space:]].*', '#', synonyms_once )
        synonyms_once <- synonyms_once[ synonyms_once != c('#','') ] %>% unlist(use.names = FALSE)
        if( length( synonyms_once ) > 0 ) 
                synonyms <<- c( synonyms, synonyms_once) %>% unique() 
}

getDeclension <- function( page_html ) {
        page_html -> page_html
        form_class <- page_html %>% html_node( xpath = form_class_xpath ) %>% html_text()
        
        if( length( i <- grep( "przysłówek", form_class ) ) ) {
                form_word <<- "przysłówek"
                declension_df <- page_html %>% html_nodes( xpath = gradation_xpath  ) %>% html_text()
                if ( length( declension_df ) > 0 ) {
                        declension_df %<>% extract(2:3) %>% removePunctuation() 
                        declension_df <- gsub( '[[:space:]]', '', declension_df ) 
                        #declension_df %>% print()
                        declension_df %>% return()
                }
                return(NULL)
        } else {
                declension_df <- page_html %>% html_node( xpath = declension_xpath ) 
                if ( length( declension_df ) > 0 ) {
                        declension_df %<>% html_table( fill = TRUE )
                        declension_df %<>% as.data.frame() %>% set_names( make.unique( names(.) ) ) 
                }
                if( length( i <- grep( "czasownik", form_class ) ) ) {
                        if( length( i <- grep( "dk.", form_class ) ) 
                            & !length(i <- grep( "dk. brak", form_class ) ) ){
                                form_word <<- "czasownik"
                                gsub( ".*dk\\. (.+?)\\).*", "\\1", form_class ) %>% getWords() %>% return()
                        } else { 
                                form_word <<- "czasownik"
                                if ( length( declension_df ) > 0 ) {
                                        declension_df %<>% select( contains( "forma" ) | starts_with( "liczba" ) )
                                        declension_df %<>% filter( forma %in% conjugation_forms )   %>% return()
                                        #declension_df <- gsub( ' się', '', declension_df ) 
                                        # declension_df %>% return()
                                }
                        }
                } else if( length( i <- grep( "przymiotnik|rzeczownik", form_class[ 1 ] ) ) ){
                        if( length( i <- grep( "przymiotnik", form_class ) ) )
                                form_word <<- "przymiotnik"
                        else form_word <<- "rzeczownik"
                        if ( length( declension_df ) > 0 ) {
                                declension_df %<>% select( contains( "przypadek" ) | starts_with( "liczba" ) )
                                declension_df %<>% filter( przypadek %in% declension_forms )  %>% return()
                        } else {
                                form_word <<- 'brak odmiany' 
                                return()
                        }
                } 
        }
}

getWords <- function( word ) {
        word <- word
        url <- paste(wiki_href, word, sep = "")
        tryCatch(
                expr = {
                        page_html <- url %>% read_html()
                        Sys.sleep( 1.5 )
                        updateSynonyms( page_html )
                        updateCognates( page_html )
                        return ( getDeclension( page_html ) )
                },
                error = function( e ) { 
                        return( word )
                        print( e )
                }
        )
}

retrieve <- function( word ) {
        tryCatch(
                expr = {
                        print( word )
                        declension <- word %>% getWords()
                        if ( !form_word %in% c( 'przysłówek', 'brak odmiany' ) ) {
                                declension %<>% select( starts_with( "liczba" ) )
                                declension %<>% unlist( use.names = FALSE) %>% unique()
                                #declension %<>% paste( collapse=',' ) 
                                return( declension )
                        } else return ( c( word, declension ) )
                },
                error = function( e ){ 
                        return( word )
                        print( e )
                }
        )
}

appendWord <- function( wordParams, declension, dest ) {
        
        rId  <- wordParams[ 'rId' ]
        deph  <- wordParams[ 'deph' ]
        typ  <- wordParams[ 'typ' ]
        tpId <- wordParams[ 'tpId' ]
        cat  <- wordParams[ 'cat' ]
        
        if( dest == 'R' ) {
                df <- data.frame( id = rId, deph = deph, type = typ, type_id = tpId, 
                                  word = declension, form = form_word, category = cat )
                file_loc = "./register_hatred.csv"
        } else if ( dest == 'D' ) {
                df <- data.frame( Id = rId, deph = deph, type = typ, type_id = tpId,
                                  declension = declension )
                file_loc = "./declension_hatred.csv"
               
        }
        write.table( df, file = file_loc, append = T, sep = ';', row.names = F, 
                     col.names = F, fileEncoding = "windows-1250" )
}

resetResemblingWords <- function() {
        synonyms <<- NULL
        cognates <<- NULL
}

handleResemblingWords  <- function( wordParams, resemblingWords ) {
        if( wordParams[ 'typ' ] == 'S' )
                message <- '---synonyms-row-%s---'
        else if( wordParams[ 'typ' ] == 'C' )
                message <- '---cognates-row-%s---'
        
        sprintf( message, row ) %>% print
        
        if( length( resemblingWords ) > 0 )
                for( word in resemblingWords ) {
                        if( !word %in% wordRegister & !is.na( word ) ) {
                                declension <- retrieve( word ) 
                                wordParams[ 'tpId' ] <- which( resemblingWords == word )
                                appendWord( wordParams, declension, 'D' )
                                appendWord( wordParams, word, 'R' )
                        }
                }
        
        wordRegister <<- c( wordRegister, resemblingWords ) %>% unique
}




