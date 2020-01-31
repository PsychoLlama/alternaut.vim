func! s:FindTestFile(directory, lang_definition, file_name) abort
  " Example: ['__tests__/', 'tests/']
  for l:convention in a:lang_definition.directory_naming_conventions
    let l:test_file_directory = a:directory . '/' . l:convention

    " Example: ['test_{name}.{ext}']
    for l:pattern in a:lang_definition.file_naming_conventions
      " Example: ['ts', 'js']
      for l:file_ext in a:lang_definition.file_extensions
        let l:ctx = { 'name': a:file_name, 'ext': l:file_ext }
        let l:test_file_name = alternaut#pattern#Interpolate(l:pattern, l:ctx)
        let l:result = findfile(l:test_file_name, l:test_file_directory . '/**')

        if l:result isnot# ''
          return l:result
        endif
      endfor
    endfor
  endfor

  return v:null
endfunc

" Look in parent directories for something resembling the test file.
func! s:SearchUpward(starting_directory, definition, file_name) abort
  let l:current_dir = a:starting_directory

  while l:current_dir isnot# '/'
    let l:result = s:FindTestFile(l:current_dir, a:definition, a:file_name)

    if l:result isnot# v:null
      return l:result
    endif

    let l:current_dir = fnamemodify(l:current_dir, ':h')
  endwhile

  return v:null
endfunc

func! alternaut#search#FindMatchingTestFile(filetype, source_file) abort
  if !filereadable(a:source_file)
    throw "The source file doesn't exist (" . a:source_file . ').'
  endif

  let l:file_name = fnamemodify(a:source_file, ':t:r')
  let l:curdir = alternaut#utils#GetCurrentDir(a:source_file)
  let l:definition = alternaut#utils#GetLanguageConfig(a:filetype)

  return s:SearchUpward(l:curdir, l:definition, l:file_name)
endfunc

func! alternaut#search#FindParentTestDirectory(file_path, lang_definition) abort
  let l:curdir = alternaut#utils#GetCurrentDir(a:file_path)
  let l:containing_directories = split(l:curdir, '/')

  for l:test_dir in a:lang_definition.directory_naming_conventions
    if index(l:containing_directories, l:test_dir) > -1
      return l:test_dir
    endif
  endfor

  return v:null
endfunc
