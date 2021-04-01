func! s:find_test_file(directory, starting_directory, lang_definition, file_name) abort
  " Example: ['__tests__/', 'tests/']
  for l:convention in a:lang_definition.directory_naming_conventions
    let l:is_local_search = l:convention is# '.'

    if l:is_local_search && a:directory isnot# a:starting_directory
      " The '.' directory is treated special by alternaut. It only searches in
      " the current directory, and never scans upwards.
      return v:null
    endif

    let l:test_file_directory = a:directory . '/' . l:convention

    " Example: ['test_{name}.{ext}']
    for l:pattern in a:lang_definition.file_naming_conventions
      " Example: ['ts', 'js']
      for l:file_ext in a:lang_definition.file_extensions
        let l:ctx = { 'name': a:file_name, 'ext': l:file_ext }
        let l:test_file_name = alternaut#pattern#interpolate(l:pattern, l:ctx)

        " Only search one layer deep if tests are expected in the cwd.
        let l:glob = l:is_local_search ? '' : '/**'
        let l:result = findfile(l:test_file_name, l:test_file_directory . l:glob)

        if l:result isnot# ''
          return l:result
        endif
      endfor
    endfor
  endfor

  return v:null
endfunc

" Look in parent directories for something resembling the test file.
func! s:search_upward(starting_directory, definition, file_name) abort
  let l:current_dir = a:starting_directory

  while l:current_dir isnot# '/'
    let l:result = s:find_test_file(l:current_dir, a:starting_directory, a:definition, a:file_name)

    if l:result isnot# v:null
      return l:result
    endif

    let l:current_dir = fnamemodify(l:current_dir, ':h')
  endwhile

  return v:null
endfunc

func! alternaut#search#find_matching_test_file(filetype, source_file) abort
  if !filereadable(a:source_file)
    throw "The source file doesn't exist (" . a:source_file . ').'
  endif

  let l:file_name = fnamemodify(a:source_file, ':t:r')
  let l:curdir = alternaut#utils#get_current_dir(a:source_file)
  let l:definition = alternaut#config#load_conventions(a:filetype)

  if l:definition is# v:null
    return v:null
  endif

  return s:search_upward(l:curdir, l:definition, l:file_name)
endfunc

func! alternaut#search#find_parent_test_directory(file_path, lang_definition) abort
  let l:curdir = alternaut#utils#get_current_dir(a:file_path)
  let l:containing_directories = split(l:curdir, '/')

  for l:test_dir in a:lang_definition.directory_naming_conventions
    if index(l:containing_directories, l:test_dir) > -1
      return l:test_dir
    endif
  endfor

  return v:null
endfunc

func! alternaut#search#find_matching_source_file(filetype, test_file) abort
  if !filereadable(a:test_file)
    throw "The test file doesn't exist (" . a:test_file . ').'
  endif

  let l:parent_directory = alternaut#utils#get_current_dir(a:test_file)
  let l:file_name = fnamemodify(a:test_file, ':t')
  let l:lang_definition = alternaut#config#load_conventions(a:filetype)
  for l:pattern in l:lang_definition.file_naming_conventions
    let l:vars = alternaut#pattern#parse(l:pattern, l:file_name)

    if empty(l:vars)
      continue
    endif

    let l:result = s:scan_parent_directories(l:parent_directory, l:vars, l:lang_definition)
    if l:result isnot# v:null
      return l:result
    endif
  endfor

  return v:null
endfunc

" Similar to s:search_upward(...). Instead of checking adjacent test
" directories recursively, this function only checks parent directories
" 1 level deep.
func! s:scan_parent_directories(parent_directory, vars, lang_definition) abort
  for l:ext in a:lang_definition.file_extensions
    let l:source_file_name = a:vars.name . '.' . l:ext
    let l:result = findfile(l:source_file_name, a:parent_directory . ';')

    if l:result isnot# ''
      return l:result
    endif
  endfor

  return v:null
endfunc
