---
title: "Dependent APIs and expires_in in Cucumber"
layout: post
---
The setup:

* Cucumber
* Capybara
* `capybara-webkit`
* A running Rails API (started up using [vegetable_glue](http://github.com/johnbintz/vegetable_glue/))
* Active Resource for moving objects around

The problem:

A particular dependent API request wasn't making it back to the app under test nor the browser. The
request was actually being proxied through the app, pretty much raw from the API and not re-run
through Active Resource before being sent to the browser.

The issue:

An `expires_in` in the controller method was sending along cache information, causing the stale data to
be cached *somewhere*.

The solution:

In `config/environments/cucumber.rb` on the API:

{% highlight ruby %}
module ActionController::ConditionalGet
  def expires_in(*args) ; end
end
{% endhighlight %}

Punch them ducks!

