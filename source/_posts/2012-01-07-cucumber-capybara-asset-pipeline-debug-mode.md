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

You're welcome.
