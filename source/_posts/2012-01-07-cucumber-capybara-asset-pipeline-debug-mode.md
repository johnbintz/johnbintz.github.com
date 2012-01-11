---
title: Cucumber, Capybara, and Rails Asset Pipeline in debug mode
layout: post
---
Because who wants to recompile all their assets on each run?

## features/support/env.rb
{% highlight ruby %}
Capybara.server_port = 3001
Capybara.app_host = "http://localhost:3001"

ActionController::Base.asset_host = Capybara.app_host
{% endhighlight %}

## config/environments/cucumber.rb
{% highlight ruby %}
config.assets.enabled = true
config.assets.debug = true
{% endhighlight %}

You're welcome.
