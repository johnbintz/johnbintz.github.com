---
title: The cleanest Bundler env
layout: post
---
Running commands in a Bundler-enabled app that has a Git repo attached to it makes running Bundler in subshells a pain.
`Bundler.with_clean_env` gets close, but still leaves enough of Bundler around to be unpleasant. This kills it dead
in subshells:

{% highlight ruby %}
module Bundler
  class << self
    def with_sparkling_clean_env
      oenv = ENV.to_hash

      %w{BUNDLE_GEMFILE RUBYOPT GEM_HOME GIT_DIR GIT_WORK_TREE}.each { |key| ENV.delete(key) }

      yield

      ENV.replace(oenv)
    end
  end
end
{% endhighlight %}

