let s:REQUIRED_KEYS = ['file_naming_conventions', 'directory_naming_conventions', 'file_extensions']

func! alternaut#config#load_conventions(filetype) abort
  let l:all_conventions = get(g:, 'alternaut#conventions', {})
  let l:ft_conventions = get(l:all_conventions, a:filetype, v:null)

  if l:ft_conventions isnot# v:null
    return s:validate_conventions(l:ft_conventions, a:filetype)
  endif

  return v:null
endfunc

func! s:validate_conventions(conventions, filetype) abort
  for l:key in s:REQUIRED_KEYS
    if !has_key(a:conventions, l:key)
      call alternaut#print#error('Error:')
      call alternaut#print#(' the alternaut conventions for ')
      call alternaut#print#code(a:filetype)
      call alternaut#print#(' are invalid.')

      " TODO: Link to a help page.

      return v:null
    endif
  endfor

  return a:conventions
endfunc
