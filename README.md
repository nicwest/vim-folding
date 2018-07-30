vim-folding
===========

[![Build Status](https://travis-ci.org/nicwest/vim-folding.svg?branch=master)](https://travis-ci.org/nicwest/vim-folding)

folding for various languages

![folding](https://upload.wikimedia.org/wikipedia/commons/2/23/Blintz-fold.jpg)


* python
* go


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
