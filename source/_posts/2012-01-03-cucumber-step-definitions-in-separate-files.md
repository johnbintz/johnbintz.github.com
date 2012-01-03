---
title: "Experiment: Cucumber step definitions in separate files"
layout: post
---
I've been getting back into using [Cucumber](http://cukes.info/) for integration/acceptance testing,
but I didn't want to repeat one of the mistakes I made in the past: bloated step definition files.
There were often step definitions I wanted to use globally for things like making files and such, and
I didn't want to have `massive_file_steps.rb` with 100 step definitions anymore.

So instead of having a setup like this:

    features/
      step_definitions/
        foo_steps.rb
        bar_steps.rb
      foo.feature
      bar.feature

With `foo_steps.rb` containing code like this:

{% highlight ruby %}
Given /I have a cat/ do
  @cat = Cat.new
end

When /I pet the cat/ do
  @result = @cat.pet
end

Then /the cat should not have hissed/ do
  @cat.should_not have_hissed
end
{% endhighlight %}

I am now trying this:

    features/
      step_definitions/
        given/
          i_have_a_cat.rb
        when/
          i_pet_the_cat.rb
        then/
          cat_should_not_have_hissed.rb
      foo.feature
      bar.feature

It seems to be working so far, but we'll see how it scales.

