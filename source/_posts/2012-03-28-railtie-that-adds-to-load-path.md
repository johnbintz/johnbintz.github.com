---
layout: post
title: Railtie that adds to load paths
---

Have to add paths via a Railtie (not an Engine)? Use `config.before_configuration`:

{% highlight ruby %}
module MyCoolGem
  class Railtie < ::Rails::Railtie
    config.before_configuration do |app|
      app.paths['app/helpers'] << File.expand_path('../../../app/helpers', __FILE__)
      app.paths['app/views'] << File.expand_path('../../../app/views', __FILE__)
    end
  end
end
{% endhighlight %}

