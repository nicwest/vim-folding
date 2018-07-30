setlocal foldmethod=expr
setlocal foldexpr=GetGoFold(v:lnum)
setlocal foldtext=GetGoFoldText()

let s:type_func = '\(func\|type\)\s'
let s:type_func_var = '\(func\|type\|var\)\s'

function! GetGoFold(lnum) abort
  let l:line = getline(a:lnum)
  if l:line =~# '^' . s:type_func
    return '>1'
  endif

  let l:next = getline(a:lnum + 1)

  if l:next =~# '^' . s:type_func_var
    return '<1'
  endif
  return -1
endfunction

function! s:get_go_fold_text(start, end) abort
  return getline(a:start)
endfunction

function! GetGoFoldText() abort
  return s:get_go_fold_text(v:foldstart, v:foldend)
endfunction
