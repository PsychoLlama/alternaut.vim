func! s:FindTestFile(directory, lang_definition, file_name) abort
  " Example: ['__tests__/', 'tests/']
  for l:convention in a:lang_definition.directory_naming_conventions
    let l:dir = a:directory . '/' . l:convention

    " Example: ['.test.ts', '.test.js']
    for l:file_ext in a:lang_definition.extensions
      let l:test_file = l:dir . '/' . a:file_name . l:file_ext

      if filereadable(l:test_file)
        return l:test_file
      endif
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

  if !has_key(g:alternaut#private#languages, a:filetype)
    throw "No language definition for file type '" . a:filetype . "'."
  endif

  let l:definition = g:alternaut#private#languages[a:filetype]
  return s:SearchUpward(l:curdir, l:definition, l:file_name)
endfunc
