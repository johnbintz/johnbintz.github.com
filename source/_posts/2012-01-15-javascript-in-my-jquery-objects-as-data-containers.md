---
title: "JavaScript in my jQuery: Objects as data containers"
layout: post
---
Sometimes you have to pass in options to jQuery functions like this:
{% highlight js %}
$('div').animate({
  height: '300px',
  opacity: 0.75,
});
{% endhighlight %}

This:

{% highlight js %}
{
  height: '300px',
  opacity: 0.75
}
{% endhighlight %}

is the most basic form of an *Object*. Objects have two things: *properties*
and *methods*. When you attach other things to an object, like the String `300px`
or the Number `0.75`, you're creating properties.

*Methods* are Functions attached to an object. When you extend `jQuery.fn` with your
own jQuery actions, you're creating a new method:

{% highlight js %}
$.fn.makeAllTranslucent = function() {
  $(this).animate({
    height: '300px',
    opacity: 0.75
  });

  return this;
};

// now you have a shortcut!
$('div').makeAllTranslucent();
{% endhighlight %}

You can add and change properties on an object after-the-fact, too:

{% highlight js %}
var properties = { height: "300px" };
if confirm("Want them translucent?") {
  properties.opacity = 0.75;
}

// pass the object in as the first parameter
$('div').animate(properties);
{% endhighlight %}

Because of the way JavaScript is designed, everything is an object: the
one you created with `{curly: 'brackets'}`, `$.fn`, standalone Functions,
everything. This lets developers do some very clever things with JavaScript.

