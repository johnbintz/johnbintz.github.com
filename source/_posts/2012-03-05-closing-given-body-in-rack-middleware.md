---
title: Closing the given body in Rack middleware
layout: post
---

Here's one that was biting my bum: [`rack-livereload`](https://github.com/johnbintz/rack-livereload/) started generating a bunch
of thread deadlock errors left and right for users. One commenter on the bug thread mentioned that middleware need to close the
body, which I had never heard of before. Turns out it's not as well-documented a practice that I would have hoped.

It boils down to trying to close the `body` that you get after you `call` your app, in case for some reason it passes you an
open file handle (which I guess is a thing?)

{% highlight ruby %}
class MyMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    dup._call(env) # <= the thing I thought would fix the deadlocks
  end

  def _call(env)
    [ status, headers, body ] = @app.call(env)

    new_body = []
    body.each { |line| new_body << line }
    body.close if body.respond_to?(:close) # <= the thing I really had to do

    # ...process stuff...

    [ status, headers, new_body ]
  end
end
{% endhighlight %}

So this is mainly so I remember to do this from now on, and for anyone else who runs into thread deadlock issues with Rack middleware.

