let s:suite = themis#suite('go')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:s = s:scope.funcs('ftplugin/go.vim')

function! s:suite.before() abort
  new test_go.go
  source ./ftplugin/go.vim
endfunction

function! s:suite.after() abort
  bwipe!
endfunction

function! s:get_fold_levels() abort
  return map(range(1, line('$')-1), 'foldlevel(v:val)')
endfunction

function! s:get_foldexpr_output() abort
  return map(range(1, line('$')-1), 'GetGoFold(v:val)')
endfunction

function! s:suite.before_each() abort
  norm! gg"_dG
  set filetype=go
  set noexpandtab
endfunction

function! s:suite.foldexpr_is_set() abort
  call s:assert.equals(&foldmethod, 'expr')
  call s:assert.equals(&foldexpr, 'GetGoFold(v:lnum)')
endfunction

function! s:suite.top_level_imports_are_never_folded() abort
  call append(0, [
  \ 'import (',
  \ '	"database/sql"',
  \ '	"time"',
  \ '',
  \ '	"github.com/shopspring/decimal"',
  \ ')'
  \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [0, 0, 0, 0, 0, 0])
endfunction

function! s:suite.functions_are_folded() abort
  call append(0, [
  \ 'func Hello(who string) string {',
  \ '	return fmt.Sprintf("Hello %s!", who)',
  \ '}',
  \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1])
endfunction


function! s:suite.structs_are_folded() abort
  call append(0, [
  \ 'type Bonkers struct {',
  \ '	This string',
  \ '	is string',
  \ '	SPARTA int',
  \ '}',
  \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1])
endfunction
