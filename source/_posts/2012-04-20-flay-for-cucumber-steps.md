---
title: "Experiment: flay for Cucumber steps"
layout: post
---

I'm no code metrics freak, but it's good to check that stuff every once in a while. Cucumber steps tend to get kind of
nasty after a while (at least for me), so I'm trying an experiment where I run [flay](http://ruby.sadi.st/Flay.html)
on the steps after a successful run, just to make sure I'm not duplicating too much between step definitions.

Save this to `features/support/flay.rb` and tweak `flay_level` to a sane number. 0 is probably not the right setting
if you want to keep your sanity.

{% gist 2431132 %}

