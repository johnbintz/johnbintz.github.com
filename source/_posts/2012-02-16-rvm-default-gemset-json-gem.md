---
title: RVM, the JSON gem, the @global gemset, and rb_gc bugs
layout: post
---
Upon building Ruby 1.9.3-p125 on my Snow Leopard Mac and getting ready to take it for a spin, trying to run anything of note in a Rails app brought the following cryptic error:

    [BUG] cross-thread violation on rb_gc()
    (null)

    Abort trap

Digging into Console.app, the backtrace indicated that the system `libruby.1.dylib` was being accessed from the C parser in the `json` gem living in the `@global`
RVM gemset. `otool -L` confirmed that the parser in the `@global` gemset was linked against system ruby, not RVM ruby. Installing a new `json` gem into the current gemset didn't work, as RVM prefers to use the `@global` version of the gem over the one in the current gemset,
it seems. Deleting the gems from the `@global` gemset and reinstalling the `json` gem in the current gemset worked, and I'm sure I could have reinstalled the
`json` gem globally too.

