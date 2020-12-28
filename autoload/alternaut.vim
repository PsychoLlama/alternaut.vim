func! alternaut#locate_test_file(source_file_path) abort
  let l:file_path = fnamemodify(a:source_file_path, ':p')
  return alternaut#search#find_matching_test_file(&filetype, l:file_path)
endfunc

func! alternaut#locate_source_file(test_file_path) abort
  let l:file_path = fnamemodify(a:test_file_path, ':p')
  return alternaut#search#find_matching_source_file(&filetype, l:file_path)
endfunc

func! alternaut#is_test_file(file_path) abort
  let l:full_file_path = fnamemodify(a:file_path, ':p')
  let l:lang_definition = alternaut#config#load_conventions(&filetype)

  if l:lang_definition is# v:null
    return v:false
  endif

  if alternaut#search#find_parent_test_directory(a:file_path, l:lang_definition) isnot# v:null
    return v:true
  endif

  return v:false
endfunc

func! alternaut#edit_test_file(...) abort
  let l:source_file_path = get(a:000, 0, expand('%:p'))
  let l:test_file_path = alternaut#locate_test_file(l:source_file_path)

  if l:test_file_path is# v:null
    echohl Error
    echon 'Error:'
    echohl Clear
    echon " Can't find the test file."
    return
  endif

  execute 'edit ' . fnameescape(l:test_file_path)
endfunc

func! alternaut#edit_source_file(...) abort
  let l:test_file_path = get(a:000, 0, expand('%:p'))
  let l:source_file_path = alternaut#locate_source_file(l:test_file_path)

  if l:source_file_path is# v:null
    echohl Error
    echon 'Error:'
    echohl Clear
    echon " Can't find the source file."
    return
  endif

  execute 'edit ' . fnameescape(l:source_file_path)
endfunc

func! alternaut#toggle() abort
  let l:file_path = expand('%:p')
  if alternaut#is_test_file(l:file_path)
    call alternaut#edit_source_file(l:file_path)
  else
    call alternaut#edit_test_file(l:file_path)
  endif
endfunc
