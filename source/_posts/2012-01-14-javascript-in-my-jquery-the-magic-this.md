---
title: "JavaScript in my jQuery: the magic $(this)"
layout: post
---
Say you're looping over some elements on the page:

{% highlight html %}

<div>One</div>
<div>Two</div>
<div>Three</div>

<script type="text/javascript">
$('div').each(function() {
  $(this).addClass('unvisited');
});
</script>
{% endhighlight %}

Within the *anonymous function*:

{% highlight js %}
function() {
  $(this).addClass('unvisited');
}
{% endhighlight %}

`this` becomes each jQuery object found in `$('div')` in turn. But how?

That `this` normally means *the object running the current code*:

{% highlight javascript %}
// create a class constructor
function Cat(name) {
  this.name = name;
}

// add a method to the object
Cat.prototype.hiss = function() {
  return this.name + " is hissing at you!";
}

// instantiate a Cat
var myCat = new Cat("Fluffy");

// work with our cat
console.log(myCat.name); // => Fluffy
console.log(myCat.hiss()); // => Fluffy is hissing at you!
{% endhighlight %}

But JavaScript lets you change `this` to whatever object you want using `Function#apply`:

{% highlight javascript %}
function Dog(name) {
  this.name = name;
}

var dog = new Dog("Bruiser");

// Cat.prototype.hiss is an object of type Function
console.log(Cat.prototype.hiss.apply(dog)); // => Bruiser is hissing at you!
{% endhighlight %}

jQuery does this with the `jQuery.fn#each` method when looping over things like DOM elements. `this`
becomes a jQuery object for each DOM node in turn:

{% highlight javascript %}
$('div').each(function() {
  // the first run through, `this` is $('div:eq(0)')
  console.log($('div:eq(0)').attr('class')); // => ''
  console.log($('div:eq(1)').attr('class')); // => ''

  $(this).addClass('uninvited');
  console.log($('div:eq(0)').attr('class')); // => 'uninvited'
  console.log($('div:eq(1)').attr('class')); // => ''
});
{% endhighlight %}

For polyglots: This is very similar in concept to how `instance_eval` can be used in Ruby:

{% highlight ruby %}
code = lambda { puts @name }

class Dog
  def initialize(name) ; @name = name ; end
end

my_dog = Dog.new("Bruiser")

my_dog.instance_eval(&code) #=> "Bruiser"
{% endhighlight %}

