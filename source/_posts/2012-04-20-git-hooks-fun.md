---
title: git hooks fun
layout: post
---

Doing some work on [penchant](http://github.com/johnbintz/penchant) I learned a few things about git hooks:

* You can add things to the commit in `pre-commit` but not `commit-msg`. By the time you got there, it's too late.
* Be sure to always `unset` (and restore if necessary) `GIT_DIR` before doing anything else involving other git repos, like running `bundle`.

