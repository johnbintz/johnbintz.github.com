---
layout: post
title: That sense of tmux cameraderie
---

I've switched to [`tmux`](http://tmux.sf.net/) and wanted to simplify my life as best as I can when using it, so I tried a few tmux gems to manage configs
and decided on [`teamocil`](http://github.com/remiprev/teamocil). However, like anything involving
a terminal multiplexer, it needs massaging *(Teamocil may cause numbness of the extremities.)*:

{% highlight bash %}
# ~/.bash_profile

tmc() {
  tmux has -t $1 && tmux attach -t $1 || tmux new -s $1 "teamocil $1"
}

function _tmc() {
  local IFS=$'\n'
  local cur="$2"
  COMPREPLY=($(compgen -W "$(find ~/.teamocil -type f | sed 's#^.*/\(.*\)\.yml$#\1#' )" -- "${cur}"))
}

complete -F _tmc tmc
{% endhighlight %}

{% highlight ini %}
# ~/.tmux.conf

set -g base-index 0
{% endhighlight %}

Then, don't use the `session` key in your configs:

{% highlight yaml %}
# ~/.teamocil/johnbintz-gh.yml

windows:
  - name: vim
    root: ~/Projects/johnbintz-gh
    splits:
      - cmd: vim
        height: 90
      - cmd: be rake preview
        height: 10
{% endhighlight %}

And finally, `tmc johnbintz-gh` will start or rejoin an exisiting Teamocil-configured session.

I could've sworn my terminal management just got easier. Or not. I think hallucination is one of the side effects of Teamocil. *(It isn't.)*

