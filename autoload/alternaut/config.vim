let s:REQUIRED_KEYS = ['file_naming_conventions', 'directory_naming_conventions', 'file_extensions']

func! alternaut#config#load_interceptors(filetype) abort
  " Support the legacy interceptor registry.
  if !exists('alternaut#interceptors')
    return get(g:alternaut#private#interceptors, a:filetype, [])
  endif

  let l:all_interceptors = get(g:, 'alternaut#interceptors', {})
  let l:interceptors = get(l:all_interceptors, a:filetype, [])

  for l:interceptor in l:interceptors
    if type(l:interceptor) isnot# v:t_func
      call alternaut#print#error('Error:')
      call alternaut#print#(" interceptors must be functions.\n")
      call alternaut#print#('See ')
      call alternaut#print#code(':help alternaut#interceptors')
      call alternaut#print#(' for details.')

      return []
    endif
  endfor

  return l:interceptors
endfunc

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
      call alternaut#print#(' the conventions for ')
      call alternaut#print#code(a:filetype)
      call alternaut#print#(" are invalid.\n")
      call alternaut#print#('See ')
      call alternaut#print#code(':help alternaut#conventions')
      call alternaut#print#(' for details.')

      return v:null
    endif
  endfor

  return a:conventions
endfunc
