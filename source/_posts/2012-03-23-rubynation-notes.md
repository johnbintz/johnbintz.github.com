---
layout: post
title: RubyNation notes from talks I went to
---

## JRuby and threading

{% highlight ruby %}
import java.util.concurrent

service = Executors.new_fixed_thread_pool
service.execute { codes }

service.shutdown
service.await_termination
service.shutdown_now
{% endhighlight %}
