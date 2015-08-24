---
title: Install haskell locally without root permission
date: August 24, 2015
tags: haskell
description: Install GHC and Cabal manually
---

Official Guide

[https://www.haskell.org/downloads/linux][haskell]

## Prepare haskell packages

Glasgow Haskell Compiler (GHC)

[https://www.haskell.org/ghc/download][ghc]

Cabal-install

[http://hackage.haskell.org/package/cabal-install][cabal]

## Install haskell packages
``` bash
tar xf ghc-7.10.2-x86_64-unknown-linux-deb7.tar.xz
cd ghc-7.10.2/
./configure --prefix=/home/wshi/.cabal
make install
cd
tar xf cabal-install-1.22.6.0.tar.gz
cd cabal-install-1.22.6.0/
./bootstrap.sh
cabal update
rm -f ghc-7.10.2-x86_64-unknown-linux-deb7.tar.xz cabal-install-1.22.6.0.tar.gz
```

[haskell]: https://www.haskell.org/downloads/linux
[ghc]: https://www.haskell.org/ghc/download
[cabal]: http://hackage.haskell.org/package/cabal-install
