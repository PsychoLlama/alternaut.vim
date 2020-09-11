let s:Types = { 'Var': 'variable', 'Literal': 'literal' }

" f('{var}.js', { 'var': 'yolo' }) = 'yolo.js'
func! alternaut#pattern#interpolate(pattern, context) abort
  let l:result = a:pattern

  for l:key in keys(a:context)
    let l:value = a:context[l:key]
    let l:substitution_pattern = '{' . l:key . '}'
    let l:result = substitute(l:result, l:substitution_pattern, l:value, 'g')
  endfor

  call s:assert_all_vars_interpolated(l:result)

  return l:result
endfunc

func! s:assert_all_vars_interpolated(string) abort
  let l:unknown_sub = matchstr(a:string, '\v\{.*\}')
  if strlen(l:unknown_sub)
    throw 'alternaut.vim: can''t interpolate unknown variable "' . l:unknown_sub . '"'
  endif
endfunc

" f('file.test.js', '{name}.test.{ext}') = { 'name': 'file', 'ext': 'js' }
func! alternaut#pattern#parse(pattern, filename) abort
  let l:tokens = s:tokenize_file_pattern(a:pattern)
  let l:regexp = s:convert_pattern_to_regexp(l:tokens)
  let l:result = {}

  let l:matches = matchlist(a:filename, l:regexp)[1:]
  let l:match_index = 0

  " The pattern doesn't match the file name.
  if empty(l:matches)
    return l:result
  endif

  " Associate regexp matches with their pattern names.
  while !empty(l:tokens)
    let l:token = remove(l:tokens, 0)

    if l:token.type is# s:Types.Var
      let l:result[l:token.value] = l:matches[0]
      call remove(l:matches, 0)
    endif
  endwhile

  return l:result
endfunc

" f('{name}.test.{ext}') = '\C\V\^\(\.\*\).test.\(\.\*\)\$'
func! s:convert_pattern_to_regexp(tokens) abort
  let l:regexp = '\C\V\^'

  for l:token in a:tokens
    if l:token.type is# s:Types.Literal
      let l:regexp .= l:token.value
    else
      let l:regexp .= '\(\.\*\)'
    endif
  endfor

  return l:regexp . '\$'
endfunc

" f('{name}.test.{ext}') = [{ 'type': 'variable', 'value': 'name' }, ...]
func! s:tokenize_file_pattern(pattern) abort
  let l:ctx = { 'active': s:Types.Literal, 'buffer': '', 'result': [] }

  func! l:ctx.Flush() abort closure
    if l:self.buffer is# ''
      return
    endif

    let l:entry = { 'type': l:self.active, 'value': l:self.buffer }
    call add(l:self.result, l:entry)
    let l:ctx.buffer = ''
  endfunc

  let l:index = 0
  while l:index < strlen(a:pattern)
    let l:char = a:pattern[l:index]
    if l:char is# '{'
      call l:ctx.Flush()
      let l:ctx.active = s:Types.Var
    elseif l:char is# '}'
      call l:ctx.Flush()
      let l:ctx.active = s:Types.Literal
    else
      let l:ctx.buffer .= l:char
    endif

    let l:index += 1
  endwhile

  return l:ctx.result
endfunc
