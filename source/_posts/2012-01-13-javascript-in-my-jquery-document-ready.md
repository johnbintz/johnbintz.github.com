---
title: "JavaScript in my jQuery: $(document).ready()"
layout: post
---
In jQuery, you normally write code like this to do something after the whole page loads:

{% highlight html %}
<script type="text/javascript">
  // the long way...
  $(document).ready(function() {
    $('#login-box').show('slow');
  });

  // the short way...
  $(function() {
    $('#login-box').show('slow');
  });
</script>
{% endhighlight %}

There's two things going on here:

* You're attaching an *event handler* to a thing that *fires* an event. Specifically, the event that fires when
  all the parts of your Web page have finished loading and that the *document* is *ready*.
* That event handler:

  {% highlight javascript %}
  function() {
    $('#login-box').show('slow');
  }
  {% endhighlight %}

  is what's known as an *anonymous function*. Normally functions get names:

  {% highlight javascript %}
  function doSomething() {
    $('#login-box').show('slow');
  }
  {% endhighlight %}
  But, you can also create a function that doesn't have a name...it's *anonymous*. You use these a lot in jQuery.
  They come in pretty handy and have a lot of interesting properties.

