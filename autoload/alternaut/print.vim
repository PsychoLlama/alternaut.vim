" Syntax-highlighted echo messages.
func! s:print(highlight_token, messages) abort
  execute 'echohl ' . a:highlight_token
  echon join(a:messages, '')
  echohl None
endfunc

func! alternaut#print#error(...) abort
  call s:print('Error', a:000)
endfunc

func! alternaut#print#string(...) abort
  call s:print('String', a:000)
endfunc

func! alternaut#print#function(...) abort
  call s:print('Function', a:000)
endfunc

func! alternaut#print#code(...) abort
  call s:print('Comment', a:000)
endfunc

func! alternaut#print#(...) abort
  call s:print('None', a:000)
endfunc
