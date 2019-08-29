let s:suite = themis#suite('python')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:s = s:scope.funcs('ftplugin/python.vim')

function! s:suite.before() abort
  new test_python.py
  source ./ftplugin/python.vim
endfunction

function! s:suite.after() abort
  bwipe!
endfunction

function! s:get_fold_levels() abort
  return map(range(1, line('$')-1), 'foldlevel(v:val)')
endfunction

function! s:get_foldexpr_output() abort
  return map(range(1, line('$')-1), 'GetPythonFold(v:val)')
endfunction

function! s:suite.before_each() abort
  norm! gg"_dG
  set filetype=python
  set tabstop=4
  set softtabstop=4
  set shiftwidth=4
endfunction

function! s:suite.number_of_spaces() abort
  call s:assert.equals(s:s.number_of_spaces('foobar'), 0)
  call s:assert.equals(s:s.number_of_spaces('    return 1'), 4)
  call s:assert.equals(s:s.number_of_spaces('        return 1'), 8)
  call s:assert.equals(s:s.number_of_spaces('        **kwargs'), 8)
endfunction

function! s:suite.foldexpr_is_set() abort
  call s:assert.equals(&foldmethod, 'expr')
  call s:assert.equals(&foldexpr, 'GetPythonFold(v:lnum)')
endfunction


function! s:suite.top_level_imports_are_never_folded() abort
  call append(0, [
    \ 'import foobar',
    \ 'import lolbeans',
    \ 'import bigbutts',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [0, 0, 0])
endfunction

function! s:suite.top_level_froms_are_never_folded() abort
  call append(0, [
    \ 'from foo import bar',
    \ 'from lol import beans',
    \ 'from big import butts',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [0, 0, 0])
endfunction

function! s:suite.top_level_froms_with_multiple_imports_are_never_folded() abort
  call append(0, [
    \ 'from foo import (bar, hah, tar, car)',
    \ 'from lol import (beans, means, heinz',
    \ '                 leans, deans, feinds)',
    \ 'from big import (',
    \ '    butts,',
    \ '    and)',
    \ 'from big import (',
    \ '    I,',
    \ '    cannot,',
    \ '    lie,',
    \ ')'
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
endfunction

function! s:suite.functions_are_folded() abort
  call append(0, [
    \ 'def its_hammer_time():',
    \ '    """something something',
    \ '',
    \ '    more info: darkside',
    \ '    """',
    \ '    print("hammer time!")'
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1, 1])
endfunction

function! s:suite.decorated_functions_are_folded() abort
  call append(0, [
    \ '@something_something',
    \ 'def its_hammer_time():',
    \ '    print("hammer time!")'
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1])
endfunction

function! s:suite.functions_decorated_multiple_times_are_folded() abort
  call append(0, [
    \ '@something_something',
    \ '@route("/hammer")',
    \ '@giggidy',
    \ 'def its_hammer_time():',
    \ '    print("hammer time!")'
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1])
endfunction

function! s:suite.async_functions_are_folded() abort
  call append(0, [
    \ 'async def its_hammer_time():',
    \ '    print("hammer time!")'
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1])
endfunction

function! s:suite.multiple_functions_are_folded() abort
  call append(0, [
    \ 'def its_hammer_time():',
    \ '    print("hammer time!")',
    \ '',
    \ 'def i_like(what):',
    \ '    print("{} and I cannot lie".format(what))',
    \ 'def hello_darkness():',
    \ '    exit()',
    \ '',
    \ '',
    \ 'def run_rabbit():',
    \ '    print("run run run!")',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
endfunction

function! s:suite.multi_line_functions_defs_are_folded() abort
  call append(0, [
    \ 'def count(',
    \ '        one,',
    \ '        two,',
    \ '        three):',
    \ '    return one + two + three'
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1])
endfunction

function! s:suite.multi_line_functions_defs_with_sadfaces_are_folded() abort
  call append(0, [
    \ 'def count(',
    \ '        one,',
    \ '        two,',
    \ '        three,',
    \ '    ):',
    \ '    return one + two + three'
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1, 1])
endfunction

function! s:suite.classes_are_folded() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '    """this is a description',
    \ '',
    \ '    Args:',
    \ '        some stuff: -----',
    \ '    """',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1, 1])
endfunction

function! s:suite.methods_are_folded() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '    def __init__(self, left, right):',
    \ '        self.left = left',
    \ '        self.right = right',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 2, 2, 2])
endfunction

function! s:suite.async_methods_are_folded() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '    async def foo(self):',
    \ '        print("bar")',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 2, 2])
endfunction

function! s:suite.class_methods_are_folded() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '    @classmethod',
    \ '    def from_left(cls, left):',
    \ '        return cls(left, "THIS IS RIGHT")',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 2, 2, 2])
endfunction

function! s:suite.foldtext_functions() abort
  call append(0, [
    \ 'def its_hammer_time():',
    \ '    """something something',
    \ '',
    \ '    more info: darkside',
    \ '    """',
    \ '    print("hammer time!")'
    \ ])
  norm! zX 
  call s:assert.equals(s:s.get_python_fold_text(1, 6), 'def its_hammer_time: something something')
endfunction

function! s:suite.foldtext_methods() abort
  call append(0, [
    \ '    def its_hammer_time():',
    \ '        """something something',
    \ '',
    \ '        more info: darkside',
    \ '        """',
    \ '        print("hammer time!")'
    \ ])
  norm! zX 
  call s:assert.equals(s:s.get_python_fold_text(1, 6), '----def its_hammer_time: something something')
endfunction

function! s:suite.foldtext_classes() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '    """I like big butts..."""',
    \ '',
    \ '    def __init__(self, left, right):',
    \ '        self.left = left',
    \ '        self.right = right',
    \ ])
  norm! zX 
  call s:assert.equals(s:s.get_python_fold_text(1, 6), 'class Ass: I like big butts...')
endfunction

function! s:suite.foldtext_classes_without_comments() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '',
    \ '    def __init__(self, left, right):',
    \ '        self.left = left',
    \ '        self.right = right',
    \ ])
  norm! zX 
  call s:assert.equals(s:s.get_python_fold_text(1, 6), 'class Ass')
endfunction

function! s:suite.foldtext_decorated_functions() abort
  call append(0, [
    \ '@classmethod',
    \ 'def its_hammer_time():',
    \ '    print("hammer time!")'
    \ ])
  norm! zX 
  call s:assert.equals(s:s.get_python_fold_text(1, 3), 'def @its_hammer_time')
endfunction

function! s:suite.fold_multiple_classes() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '    def __init__(self, left, right):',
    \ '        self.left = left',
    \ '        self.right = right',
    \ '',
    \ '',
    \ 'class BigButtsException:',
    \ '    def dont_lie(self):',
    \ '        print("i cannot lie")',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 2, 2, 2, 2, 2, 1, 2, 2])
endfunction

function! s:suite.does_not_fold_inline_functions_in_functions() abort
  call append(0, [
    \ 'def its_hammer_time():',
    \ '',
    \ '    def foobar():',
    \ '        print("pewpew")',
    \ '    print("hammer time!")',
    \ '    print("hammer time!")',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 1, 1])
endfunction

function! s:suite.does_not_fold_inline_functions_in_methods() abort
  call append(0, [
    \ '    def its_hammer_time(self):',
    \ '        print("hammer time!")',
    \ '        def foobar():',
    \ '            print("pewpew")',
    \ '        print("hammer time!")',
    \ '        print("hammer time!")',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [2, 2, 2, 2, 2, 2])
endfunction

function! s:suite.foldtext_classes_with_decorated_method() abort
  call append(0, [
    \ 'class Ass(object):',
    \ '',
    \ '    @kungpow',
    \ '    def chicken(self):',
    \ '        print("hahahahahah")',
    \ ])
  norm! zX 
  call s:assert.equals(s:s.get_python_fold_text(1, 5), 'class Ass')
endfunction

function! s:suite.top_level_logic_is_not_folded() abort
  call append(0, [
    \ 'def foobar():',
    \ '    print("gold fush")',
    \ '',
    \ '',
    \ 'if __name__ == "__main__":',
    \ '    foo = 1',
    \ '    bar = 2',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [1, 1, 1, 1, 0, 0, 0])
endfunction


function! s:suite.method_below_attribute_with_same_indentation_folds() abort
  call append(0, [
    \ '    def lol(self):',
    \ '        return 123',
    \ '',
    \ '    foobar = 123',
    \ '',
    \ '    def lol(self):',
    \ '        return 123',
    \ ])
  norm! zX 
  call s:assert.equal(s:get_fold_levels(), [2, 2, 2, 1, 1, 2, 2])
endfunction
