let g:alternaut#private#languages = {}

func! alternaut#RegisterLanguage(filetype, config) abort
  if type(a:filetype) isnot# v:t_string
    throw 'Alternaut needs a filetype string as the first parameter.'
  endif

  if type(a:config) isnot# v:t_dict
    throw 'Alternaut needs a config dictionary as the second parameter.'
  endif

  if type(get(a:config, 'extensions', v:null)) isnot# v:t_list
    throw 'Alternaut language config needs an "extensions" array.'
  endif

  if type(get(a:config, 'directory_naming_conventions', v:null)) isnot# v:t_list
    throw 'Alternaut language config needs a "directory_naming_conventions" array.'
  endif

  let g:alternaut#private#languages[a:filetype] = a:config
endfunc

func! alternaut#LocateTestFile(source_file_path) abort
  let l:file_path = fnamemodify(a:source_file_path, ':p')
endfunc

func! alternaut#OpenTestFile(source_file_path) abort
  " TODO
endfunc

func! alternaut#LocateSourceFile(test_file_path) abort
  " TODO
endfunc

func! alternaut#OpenSourceFile(test_file_path) abort
  " TODO
endfunc
