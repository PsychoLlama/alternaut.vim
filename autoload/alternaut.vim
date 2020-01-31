let g:alternaut#private#languages = {}

func! alternaut#RegisterLanguage(filetype, config) abort
  if type(a:filetype) isnot# v:t_string
    throw 'Alternaut needs a filetype string as the first parameter.'
  endif

  if type(a:config) isnot# v:t_dict
    throw 'Alternaut needs a config dictionary as the second parameter.'
  endif

  if type(get(a:config, 'file_naming_conventions', v:null)) isnot# v:t_list
    throw 'Alternaut language config needs a "file_naming_conventions" array.'
  endif

  if type(get(a:config, 'file_extensions', v:null)) isnot# v:t_list
    throw 'Alternaut language config needs an "file_extensions" array.'
  endif

  if type(get(a:config, 'directory_naming_conventions', v:null)) isnot# v:t_list
    throw 'Alternaut language config needs a "directory_naming_conventions" array.'
  endif

  let g:alternaut#private#languages[a:filetype] = a:config
endfunc

func! alternaut#LocateTestFile(source_file_path) abort
  let l:file_path = fnamemodify(a:source_file_path, ':p')
  return alternaut#search#FindMatchingTestFile(&filetype, l:file_path)
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
