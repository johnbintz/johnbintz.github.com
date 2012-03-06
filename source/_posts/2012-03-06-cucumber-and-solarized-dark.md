---
layout: post
title: Cucumber and Solarized Dark
---

[Solarized Dark](http://github.com/altercation/solarized/tree/master/iterm2-colors-solarized) for iTerm2 is weird in that the grey used by Cucumber to show where
a snippet comes from is nearly invisible. You can either increase the contrast (I set it to about 20%), or export a `CUCUMBER_COLORS` environment variable so
you don't have to worry about it:

    export CUCUMBER_COLORS=comment=cyan

