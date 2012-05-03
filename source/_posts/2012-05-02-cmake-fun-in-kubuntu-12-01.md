---
title: CMake fun in Kubuntu 12.04
layout: post
---

I tried building `qtbindings` on my Kubuntu 12.04 install, but CMake was complaining about a lot of missing libraries that
I knew were installed. Turns out CMake isn't searching what would be considered the new library path in 12.04, `/usr/lib/i386-linux-gnu`.
I had to `export CMAKE_LIBRARY_PATH`/usr/lib/i386-linux-gnu` to appease the CMake gods.

BTW, if `qtbindings` seems to build really really fast on your Ubuntu machine, it's probably because of this.

