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

func! alternaut#LocateSourceFile(test_file_path) abort
  let l:file_path = fnamemodify(a:test_file_path, ':p')
  return alternaut#search#FindMatchingSourceFile(&filetype, l:file_path)
endfunc

func! alternaut#IsTestFile(file_path) abort
  let l:lang_definition = alternaut#utils#GetLanguageConfig(&filetype)

  if alternaut#search#FindParentTestDirectory(a:file_path, l:lang_definition) isnot# v:null
    return v:true
  endif

  return v:false
endfunc

func! alternaut#EditTestFile(...) abort
  let l:source_file_path = get(a:000, 0, expand('%:p'))
  let l:test_file_path = alternaut#LocateTestFile(l:source_file_path)

  if l:test_file_path is# v:null
    echohl Error
    echon 'Error:'
    echohl Clear
    echon " Can't find the test file."
    return
  endif

  execute 'edit ' . fnameescape(l:test_file_path)
endfunc

func! alternaut#EditSourceFile(...) abort
  let l:test_file_path = get(a:000, 0, expand('%:p'))
  let l:source_file_path = alternaut#LocateSourceFile(l:test_file_path)

  if l:source_file_path is# v:null
    echohl Error
    echon 'Error:'
    echohl Clear
    echon " Can't find the source file."
    return
  endif

  execute 'edit ' . fnameescape(l:source_file_path)
endfunc

func! alternaut#Toggle() abort
  let l:file_path = expand('%:p')
  if alternaut#IsTestFile(l:file_path)
    call alternaut#EditSourceFile(l:file_path)
  else
    call alternaut#EditTestFile(l:file_path)
  endif
endfunc
