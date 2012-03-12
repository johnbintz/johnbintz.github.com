---
title: "Experiment: ActiveResource collection classes"
layout: post
---
Stealing an idea from [Backbone.js](http://backbonejs.org/), I decided to try using a collection
class with an ActiveResource model I was working on. The use case was for creating a tree of objects
based on an `acts_as_tree` storage method, where child objects have a `parent_id` set the same as the
parent's `id`. Here's what I originally had:

{% highlight ruby %}
class Category < ActiveResource::Base
  def self.tree
    @all = all
    @all.each { |node| node.children = [] }

    top_nodes = @all.find_all { |category| category.parent_id == nil }.sort
    top_nodes.each do |node|
      node.children = @all.find_all { |category| category.parent_id == node.id }.sort
    end
    top_nodes.sort
  end
end
{% endhighlight %}

Big, long, hard-to-cleanly-test method. Ick. Did this instead:

{% highlight ruby %}
# simple skeleton to hang more on later
class ActiveResource::Collection < ::Array
  def initialize(models)
    replace(models)
  end
end

class Category < ActiveResource::Base
  def self.tree
    Categories.new(all).tree
  end

  def top_node?
    parent_id == nil
  end
end

class Categories < ActiveResource::Collection
  def top_nodes
    find_all(&:top_node?).sort
  end

  def tree
    top_nodes.collect do |node|
      node.tap { |n| n.children = models.find_all { |model| model.parent_id == node.id }.sort }
    end.sort
  end
end
{% endhighlight %}

More lines of code, but no mess in the model itself. I'll play with the idea and see how well it scales to other situations.

