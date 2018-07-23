vim-vim folder
==== 

folding for various languages

Usage
-----

```viml
:VIM FOLDER1               " does something
:VIM FOLDER2               " does something else
```

Suggested Mappings
------------------

vim folder doesn't bind anything by default. These are the suggested
mappings:

```viml
nnoremap <Leader>p1             <Plug>VIM FOLDER1
nnoremap <Leader>p2             <Plug>VIM FOLDER2
```

Tests
-----

To run the tests pull the [themis test
suite](https://github.com/thinca/vim-themis) (you don't have to install it but
you can if you want).

```
git clone git@github.com:thinca/vim-themis.git
./vim-themis/bin/themis --reporter dot test
```

Alternatively you can use the Makefile in the root dir, which will clone the
dependencies and run the tests and linter.

```
make init
make test
make lint
```
