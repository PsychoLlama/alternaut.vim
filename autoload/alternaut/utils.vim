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

func! alternaut#utils#GetLanguageConfig(filetype, file_path) abort
  if !has_key(g:alternaut#private#languages, a:filetype)
    throw "No language definition for file type '" . a:filetype . "'."
  endif

  let l:lang_definition = g:alternaut#private#languages[a:filetype]

  for l:Interceptor in get(g:alternaut#private#interceptors, a:filetype, [])
    let l:definition_override = l:Interceptor(a:file_path, deepcopy(l:lang_definition))

    " It might return null.
    if type(l:definition_override) is# v:t_dict
      let l:lang_definition = l:definition_override
    endif
  endfor

  return l:lang_definition
endfunc
