---
title: falcon patch adventures for ruby 1.9.3
layout: post
---
OK, I got the super-cool [falcon patch](https://gist.github.com/1688857) (as it's known in rvm) working on my Snow Leopard Macs, but had a few
issues with it, and not because of the patch itself:

* For some reason, building any 1.9.3 in rvm on my machines screws up the Makefile and sticks in a circular reference to
  building the ruby executable (as in, dependency ruby => ruby). Have to always rip out that last line in the Makefile
  and `make ; make install`.
* As rvm so succinctly warned me (I had no idea `rvm requirements` existed!), GCC & associated bits in the default Snow
  Leopard XCode release are broken. I was getting segfaults on garbage collection within the cached load path part of
  the patch, which is where the real speed came from. I installed [osx-gcc-installer](https://github.com/kennethreitz/osx-gcc-installer)
  and removed the rest of XCode, then recompiled and everything worked fine.

How much of an improvement for me? 3 RSpec runs of a big app went from 2:40.742s (1.9.2-p290 with load patch) to 1:48.104s (1.9.3-p0 with falcon patch).
A 33% speed increase. Sweet.

