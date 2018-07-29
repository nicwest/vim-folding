setlocal foldmethod=expr
setlocal foldexpr=GetPythonFold(v:lnum)
setlocal foldtext=GetPythonFoldText()

let s:class_def = '\s*\(class\|def\|async def\) \([^(]\+\)(\?.*'
let s:def = '\s*\(def\|async def\) \([^(]\+\)(\?.*'
let s:decorator = '\s*@.\+'
let s:blank = '^\s*$'
let s:import = '(import\|from)'
let s:docstring = '\(' . "'''" . '\|"""\)\(.*\)$'
let s:docstring_single = '\(' . "'''" . '\|"""\)\(.*\)\(\1\)$'
let s:nested_def = '^\s\{'. &shiftwidth * 2 .',\}\S'
let s:conditional = '\(for\|while\|if\|else\|try\|except\|finally\)\(\s\|:\)\+'

function! s:number_of_spaces(line) abort
  return max([match(a:line, '\S'), 0])
endfunction

function! s:is_start_of_fold(line) abort
  return (a:line  =~ s:class_def || a:line =~ s:decorator)
endfunction

function! s:get_previous_class_def(linenr, spaces) abort
  if a:linenr == 0
    return 0
  endif
  let l:line = getline(a:linenr)
  if s:number_of_spaces(l:line) < a:spaces && l:line =~ s:class_def
    return a:linenr
  endif
  return s:get_previous_class_def(a:linenr - 1, a:spaces)
endfunction

function! GetPythonFold(lnum) abort

  if line(a:lnum) == line('$')
    echom 'end' . line('$')
    return '<1'
  endif

  let l:line = getline(a:lnum)
  let l:spaces = s:number_of_spaces(l:line)
  let l:level = (l:spaces / &shiftwidth) + 1

  if l:line =~ '^' . s:import
    return 0
  endif

  if l:line =~# '^' . s:conditional
    return 0
  endif
  
  let l:previous = getline(a:lnum-1)
  let l:previous_spaces = s:number_of_spaces(l:previous)
  let l:previous_level = (l:previous_spaces / &shiftwidth) + 1

  if s:is_start_of_fold(l:line)
    if s:is_start_of_fold(l:previous) && l:previous_spaces == l:spaces
      return l:level
    endif

    if l:spaces > 0
      let l:previous_class_def_line = s:get_previous_class_def(a:lnum, l:spaces)
      let l:previous_class_def = getline(l:previous_class_def_line)
      if l:previous_class_def =~? s:def
        return -1
      endif
    endif
    return '>' . l:level
  endif

  let l:next = getline(a:lnum+1)
  let l:next_spaces = s:number_of_spaces(l:next)
  
  if l:line =~ s:blank && s:is_start_of_fold(l:next)
    return '<' . ((l:next_spaces / &shiftwidth) + 1)
  endif

  if l:next =~# '^' . s:conditional
    return '<' . ((l:next_spaces / &shiftwidth) + 1)
  endif

  return -1
endfunction

function! s:get_python_fold_text(start, end) abort
  let l:lines = getline(a:start, a:end)
  let l:looking_for_comments = 0
  let l:has_decorators = ''
  let l:name = 'UNKNOWN'
  let l:type = '!!!'
  let l:comment = ''
  let l:indent = ''
  for l:line in l:lines
    if !l:looking_for_comments && l:line =~ s:decorator
      let l:has_decorators = '@'
    endif
    let l:m = matchlist(l:line, s:class_def)
    if len(l:m)
      if l:looking_for_comments
        break
      endif
      let l:looking_for_comments = 1
      let l:type = l:m[1]
      let l:name = l:m[2]
      let l:indent = substitute(matchstr(l:line, '^\s*'), '\s', '-', 'g')
    endif

    if l:looking_for_comments
      let l:m = matchlist(l:line, s:docstring_single)
      if len(l:m)
        let l:comment = l:m[2] 
        break
      endif
      let l:m = matchlist(l:line, s:docstring)
      if len(l:m)
        let l:comment = l:m[2] 
        break
      endif
    endif
  endfor
  if len(l:comment)
    return l:indent . l:type . ' '. l:has_decorators  . l:name . ': ' . l:comment
  else                                               
    return l:indent . l:type . ' '. l:has_decorators  . l:name
  endif
endfunction

function! GetPythonFoldText() abort
  return s:get_python_fold_text(v:foldstart, v:foldend)
endfunction
