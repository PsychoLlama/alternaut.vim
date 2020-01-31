" Return the current directory, or the containing directory
" if the current buffer is a file.
func! alternaut#utils#GetCurrentDir(file_or_directory) abort
  let l:dir = a:file_or_directory

  if l:dir is# v:null
    let l:dir = expand('%:p')
  endif

  if filereadable(l:dir)
    let l:dir = fnamemodify(l:dir, ':h')
  endif

  return l:dir
endfunc

func! alternaut#utils#GetLanguageConfig(filetype) abort
  if !has_key(g:alternaut#private#languages, a:filetype)
    throw "No language definition for file type '" . a:filetype . "'."
  endif

  return g:alternaut#private#languages[a:filetype]
endfunc
