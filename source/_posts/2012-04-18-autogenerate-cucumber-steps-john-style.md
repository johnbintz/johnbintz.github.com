---
title: Autogenerate Cucumber steps, John-style
layout: post
---
Following up on an [experiment I started earlier this year](/blog/2012/01/03/cucumber-step-definitions-in-separate-files/),
I created a Cucumber formatter that will write out undefined steps to a directory you specify. So much less copypaste for
my workflow. [Here's the project](http://github.com/johnbintz/cucumber-step_writer/).

Also, you can do the same in [Flowerbox](http://johnbintz.github.com/flowerbox/) with your JavaScript Cucumber step definitions:

{% highlight ruby %}
Flowerbox.configure do |f|
  f.reporters.add(:step_writer, :target => 'js-features/step_definitions')
end
{% endhighlight %}

