---
title: "My Hypercool Automagic Rails 3.1/Guard Setup"
layout: post
---

Here's a guide on how I set up all my Rails stuff. Having now written one, I can join the elite group of people who write guides on how they set up all
their Rails stuff.

## What this guide covers

* Rails 3.1 gem setup for maximum automagic fun and less headdesking.
* Guard setup for guarding your Rails server, RSpec tests, JavaScript testing, and LiveReloading.
* Making `jasmine-headless-webkit`, your app, and Sprockets play nice.
* Precompiling your assets locally and shoving them up to your deploy location using Capistrano.

### Why this approach?

'cause it works pretty well for me, and it's my guide, so _there_.

## Rails 3.1 Gem Setup

There are only two tricks: having `compass` load before `sass-rails` to ensure all the cool Compass bits actually work, and having all of your
asset pipeline stuff *(all of it)* in a group called `:assets`, that also happens to be part of your `:development` group. Everything else
is pretty straightforward. If you plan on using asset pipeline gems in your `jasmine-headless-webkit` setup, you can put them anywhere, as no specific
groups are loaded or required when using JHW like they are with Rails:

{% highlight ruby %}
group :assets, :development do
  gem 'compass', '~> 0.12.alpha'
  gem 'sass-rails'

  gem 'jquery-rails'
  gem 'backbone-rails'
  # ... blah blah blah ...
end

group :development do
  # for js testing...
  gem 'jasmine-headless-webkit'
  gem 'jasmine-spec-extras'

  # for laziness...
  gem 'guard'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-jasmine-headless-webkit'
  gem 'guard-livereload'

  # for awesome rack middleware
  gem 'rack-livereload'
end
{% endhighlight %}

### Why does order matter? It's a Gemfile, right?

'cause Rails (roughly) does:

{% highlight ruby %}
Bundler.require(:default, ENV['RAILS_ENV'], ENV['RAILS_GROUPS'])
{% endhighlight %}

... which requires the files in your Gemfile in the order in which they are defined. If Compass defines the necessary asset pipeline stuff first,
Sass-Rails won't stomp on it and everything works all happy-like.

## Guard setup

If you don't know Guard, the you're out of the loop. All the lazy programmers are using it. Any by "lazy" I mean super-cool.

Create a `Guardfile` for your project by doing this in your shell:

{% highlight bash %}
for guard in rails rspec jasmine-headless-webkit livereload ; do
  bundle exec guard init $guard
done
{% endhighlight %}

Then, split those Guards up into groups. I typically have three: one for the Rails server and LiveReload, one for RSpec, and one for JHW:

{% highlight ruby %}
group :test do
  guard 'rspec', :version => 2, :all_on_start => false do
    watch(%r{^spec/.+_spec\.rb}) { |m| m[0]['/acceptance/'] ? nil : m[0] }
    watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb') { "spec" }

    # Rails example
    watch('spec/spec_helper.rb')                       { "spec" }
    watch('app/controllers/application_controller.rb') { "spec/controllers" }
    watch(%r{^app/(.+)\.rb})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/views/(.*)$})                        { |m| "spec/views/#{m[1]}_spec.rb" }
    watch(%r{^lib/(.+)\.rb})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb})  { |m| ["spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  end
end

group :js do
  spec_location = "spec/javascripts/%s_spec"

  guard 'jasmine-headless-webkit', :all_on_start => false do
    watch(%r{^app/assets/javascripts/(.*)\.(js|coffee)}) { |m| newest_js_file(spec_location % m[1]) }
    watch(%r{^spec/javascripts/(.*)_spec\..*}) { |m| newest_js_file(spec_location % m[1]) }
    watch(%r{^spec/javascripts/.*_helper.coffee$}) { "spec/javascripts/**/*_spec.*" }
  end
end

group :rails do
  guard 'rails', :force_run => true, :server => :thin do
    watch(/^Gemfile.lock$/)
    watch(/^config\/.*\.(rb|yml)$/) { |m| m[0] if !m[0]['/locales/'] }
  end

  guard 'livereload', :grace_period => 1 do
    watch(%r{app\/.+\.(erb|haml|jst|hamljs|coffee)$})
    watch(%r{app/assets/stylesheets/(.*)$}) { 'assets/application.css' }
    watch(/app\/helpers\/.+\.rb/)
    watch(/config\/locales\/.+\.yml/)
  end
end
{% endhighlight %}

With the asset pipeline, you no longer need gems like `guard-coffeescript` or `guard-compass`, unless you're doing something really special.

### The `:test` group

This one's pretty standard: re-run RSpec with every change to the program code. Shouldn't need much
explaining for this one.

### The `:js` group

This one's a lot like the RSpec setup: re-run Jasmine specs with every file change, configured to look in
the most typical place that asset pipeline JavaScript files live in: `vendor/assets/javascripts`. If you're
also putting stuff into `lib/assets/javascripts` or `vendor/assets/javascripts` and want it to be part of
the trigger for re-running `jasmine-headless-webkit`, then change that first line to:

{% highlight ruby %}
watch(%r{^(app|lib|vendor)/assets/javascripts/(.*)\.(js|coffee)}) { |m| newest_js_file(spec_location % m[2]) }
{% endhighlight %}

Note that this change _does not add these folders to your Rails Sprockets configuration nor to your
`jasmine-headless-webkit` configuration._ It only tells Guard to look in those places for file operations so
that it can execute code. `app`, `lib`, and `vendor` are automatically searched for by Rails, and they're very
easy to add to `jasmine-headless-webkit`, which is what we'll get to in the next part.

### The `:rails` group

This one has a little more meat to it. First: a few notes about the Rails guard and Rails 3.1:

* There used to be a definition for `lib/.*\.rb`, but that was before I learned about `require_dependency`, which
  flags "normal" Ruby files to be reloaded in development much like files in `app`. So if there's some library file that, say, a model
  depends on, include it in your model code like this and it gets reloaded along with the parent code:

{% highlight ruby %}
require_dependency 'super_cool'

class John < ActiveRecord::Base
  include SuperCool

  # ...codes...
end
{% endhighlight %}

* Adding new locale files requires a restart of the server. That would be a good type of detection to add to `guard-rails`. If you
  want to see it, and I don't do it fast enough, go ahead and add it. I like pull requests.

Second, LiveReload. It's not entirely magic, but getting it set up "just right" can be a little tricky. There are three parts to
LiveReload:

* The LiveReload code, which has been moved to nice includable JavaScript in the latest version of LiveReload (before it was a browser extension).
* The inclusion of the LiveReload code into `text/html` pages, and any extra code to get a WebSocket connection working.
* A WebSocket server that accepts connections from browsers that are running the LiveReload code.

With the asset pipeline, we want the following to happen:

* Reload only the appropriate stylesheet(s) when a Sass file is changed.
* Reload everything if a Ruby or CoffeeScript file is changed. I'm not a fan of just reloading JavaScript, sorry.

Most apps will only have the one "main" CSS file, `application.css`. Every other Sass and CSS file gets shoved into that file via the asset pipeline, especially
if you're using Sass includes (which I do since they're a lot more flexible than Sprockets ones). If you're using Sprockets includes, enabling debug mode in
Sprockets, which you should have on in development anyway, I believe would allow you to reload specific stylesheets, but I'm more of a fan of Sass includes, so
there you go.

This Guard LiveReload setup...

{% highlight ruby %}
guard 'livereload', :grace_period => 1 do
  watch(%r{app\/.+\.(erb|haml|jst|hamljs|coffee)$})
  watch(%r{app/assets/stylesheets/(.*)$}) { 'assets/application.css' }
  watch(/app\/helpers\/.+\.rb/)
  watch(/config\/locales\/.+\.yml/)
end
{% endhighlight %}

...ensures that everything except changes to stylesheets reload the entire page. Stylesheet changes only reload the main CSS file. The `:grace_period`
ensures that Sprockets compilation catches up to the file save operations that Guard watches for before actually triggering the reload. It can
keep your browser from freaking out and reloading a ton of times on one save operation.

## Sprockets, Rails, and `jasmine-headless-webkit`, sitting in a tree...

Sprockets is pretty cool, and it makes organizing JavaScript a lot easier. I also like super-fast unit testing, with Jasmine being my test framework of choice.
There's three JavaScript unit testing-related problems with the typical Rails setup, though:

* Any `.erb` files that get data from your Rails app require you to have your app up and running to pull the data out. That's integration testing
  at that point, and I go into more detail about that on the [`jasmine-headless-webkit`](http://johnbintz.github.com/jasmine-headless-webkit/) site.
* Your Sprockets config lives in `config/application.rb` (or even deeper into specific Rails environments).
* Rails vendored JavaScript gems like `jquery-rails` let their presence be known with a Railtie.

So `jasmine-headless-webkit` does the following, in order to make unit testing JavaScript code in a Rails/Sprockets application possible:

* It ignores `.erb` files unless your Sprockets requires are incorrect. You'll know pretty quick if they are.
* It requires that you add your asset paths to `jasmine.yml`.
* All loaded gems are searched for `vendor/assets/javascripts` and any gems with that directory structure have that specific directory added to the Sprockets
  asset path.

All of this is covered on the [`jasmine-headless-webkit`](http://johnbintz.github.com/jasmine-headless-webkit/) site -- this guide will get you up and running
without a ton of explanation.

### Set up Jasmine

You can use `jasmine init` or `rails g jasmine:init`, but it's a lot faster to just make `spec/javascripts/support/jasmine.yml` and add the following contents:

{% highlight yaml %}
src_dir: app/assets/javascripts
asset_paths:
- lib/assets/javascripts
- vendor/assets/javascripts

src_files:
- "**/*"

spec_dir: spec/javascripts

spec_files:
- "**/*[Ss]pec.*"

helpers:
- "helpers/**/*"
{% endhighlight %}

This adds `app/assets/javascripts`, `lib/assets/javascripts`, `vendor/assets/javascripts`, and `spec/javascripts` to the asset path, along with any other
available vendored JavaScript directories within gems.

If you added `jasmine-spec-extras` to your Gemfile, create `spec/javascripts/helpers/spec_helper.js.coffee` with:

{% highlight coffeescript %}
#= require jasmine-jquery
#= require sinon
{% endhighlight %}

This adds `jasmine-jquery` and Sinon.js to your project, two must-haves when testing JS- and Ajax-heavy applications.

### Including JST templates

Sprockets already comes with a bunch of supported templating engines, which are included just the same as in the Rails app:

{% highlight coffeescript %}
#= require backbone
#= require views/my_app/template.jst.eco

class window.MyApp extends Backbone.View
  template: JST['views/my_app/template']
{% endhighlight %}

`jasmine-headless-webkit` also watches out for `haml-sprockets` to be available, and if it is, it gets loaded and `.hamljs` templates become available:

{% highlight ruby %}
# Gemfile

gem 'haml-sprockets'
{% endhighlight %}

{% highlight coffeescript %}
# app/assets/views/my_app.js.coffee
#
#= require views/my_app/template.jst.hamljs
{% endhighlight %}

_(want your templating engine added to JHW's search? Open an issue or fork'n'fix!)_

### Including Rails data into your JavaScript

Since `.erb` templates don't get parsed and can cause problems if included into `jasmine-headless-webkit`, you need to be careful about
including them into your application. Here's a few ways you could solve the problem if you really need that data in your JavaScript somewhere
and don't want to use Ajax. Both of these require that you stub out anything that would have normally come from Rails:

#### Put integration stuff into your view templates

For instance, giving Backbone Collections URLs dynamically:

{% highlight coffeescript %}
# app/assets/javascripts/helpers/backbone_duck_puncher.js.coffee

Backbone.Collection.prototype.initialize = (models = [], options = {}) ->
  @url = options.url || @url
{% endhighlight %}

{% highlight haml %}
-# app/views/my_app/list.html.haml

#target

:javascript
  var collection = new MyApp.Things([], { url: '<%= things_path %>' });
  (new MyApp.ThingsView(collection: collection, el: '#target')).render()
{% endhighlight %}

This gives the added bonus of being able to make sure each use of a collection also has a real URL coming along with it:

{% highlight ruby %}
# spec/views/my_app/list.html.haml_spec.rb

describe 'my_app/list.html.haml' do
  it 'should render' do
    render

    rendered.should include('MyApp.Things')
    rendered.should include('MyApp.ThingsView')
    rendered.should include(things_path)
  end
end
{% endhighlight %}

#### Put the Rails stuff into an `.erb` file that JHW doesn't see

    app/
      assets/
        javascripts/
          my_app/
          application.js.coffee     #=> does require_tree 'my_app'
          integration.js.coffee.erb #=> requires nothing, just Rails data

{% highlight haml %}
-# layouts/application.html.haml

!!!
%html
  %head
    = javascript_include_tag 'application'
    = javascript_include_tag 'integration'
{% endhighlight %}

{% highlight yaml %}
# jasmine.yml

src_dir: app/assets/javascripts
src_files:
- application.js.coffee
{% endhighlight %}

So, pick your poison. Or, move to a solution integrated with Rails, like Evergreen or modern versions of the Jasmine gem.

### Annyoing JavaScript

Unfortunately, out in the world there are still a lot of projects and code snippets that are just annyoing to plug into the
asset pipeline. Things like WYSIWYG code editors, uploading tools, and lots of other projects that, while they work and can work very well,
often do bad things to make themselves work. They may not play well with `jasmine-headless-webkit`, so I stick these _annoying JavaScript_ projects
into a `vendor-annoying/assets/javascripts` folder and only add that asset path to Rails's config. Then, if I need to use those
JavaScript files, I use a combination of both approaches above, along with just flat-out requiring those files using
`javascript_include_tag`, to get them into the app while not getting them into JHW.

## LiveReload'n

(modern versions of) LiveReload works by loading up a JavaScript file into browsers smart enough to know WebSockets, having the
browser connect to a running LiveReload WS server, and waiting for notifications from the WS server instructing the browser to
reload certain things, like just the CSS, just the JavaScript, or to reload the whole page.

`rack-livereload` is the easiest way to plug in LiveReload to the development environment of a running Rails app, and it has the
additional advantage of bringing along a copy of `web-socket-js`, a WebSocket simulator for browsers that support Flash. So you
can LiveReload away in non-bleeding edge browsers and on pretty much any mobile device, all at the same time.

With `rack-livereload` in your Gemfile under `:development`, add the middleware to `config/initializers/development.rb`:

{% highlight ruby %}
config.middleware.insert_before(Rack::Lock, Rack::LiveReload)
{% endhighlight %}

Boot up your app, load a page in your favorite browser, and make sure you get the following:

* The LiveReload script injected into the source code of your page.
* Notifications in your console of LiveReload trying to connect to a server (or actually connecting if `guard-livereload` is running).

Now, get `guard-livereload` running and change a file that it watches for. If everything is connected and working, the act of saving that
file should reload any browsers attached to the LiveReload server.

If it doesn't reload, yet `guard-livereload` says it's reloading something, try the following:

* Force-reload the browser manually to reconnect to the LiveReload server.
* Make sure the filenames getting passed to `guard-livereload` make sense. If you're trying to reload a specific file like a stylesheet,
  try removing the specific file check and make sure that whole page reloading works first.
* Restart the whole Guard. The combination of `guard-livereload` and `rack-livereload` don't like it when you just refresh the `Guardfile`.
  At least, that's been my experience.

## Production servers don't need JavaScript runtimes

Back in the Barista/Jammit days, I always precompiled all my JavaScript code, since that was what you did. Also, the servers on which I was
running some of my code were too old for building a JavaScript runtime like Node.js or `therubyracer`. While I've moved to Rails 3.1 and
away from Barista and Jammit, those servers are still too old for a JS runtime. But I'm actually of the mindset that production servers
don't really need that runtime, since you can precompile everything locally and push it up using Capistrano, or (my favorite) just re-adding all
those compiled assets to your Git repository on commit.

There are definitely disadvantages to this approach:

* If your `.erb` code requires access to, say, the data on the remote production system, this definitely won't work. I may ask why your
  JavaScript is tied so tightly to your database, but that's for another time.
* It can make Git commits kinda big and noisy, especially if a lot of JavaScript is being changed. Typically I find that it's just
  whatever files I've changed, along with the final compiled files and their `.gz` counterparts.
* Unless you're using a Git hook to do the compilation, you're going to forget to do it.

But there's one really nice advantage:

* My stupid little continuous deployment setup is super-fast, since all I have to do is the equivalent of `bundle exec cap latest deploy` on
  the Git server and away I go. No JS dependencies anywhere but my development machine.

So it's up to you how you want to do it. I'm just giving you the way that I prefer to put my assets together for production, staging, or
continuous deployment.

I use Git hooks like crazy. My `penchant` project use them to enforce test running before commit, and with that same approach, you can
generate your assets destined for whichever environment you choose. `penchant` runs `bundle exec rake` and expects an exit code of 0.
This means you can stack on some asset compilation code to your `Rakefile`'s default task, along with your test running (since you're only
running this task on Git commit, and your actual "testing" is done using Guard):

{% highlight ruby %}
task :default => [ :spec, 'jasmine:headless', :build_and_add_assets ]

task :build_and_add_assets do
  system %{bundle exec RAILS_ENV=production assets:precompile}
  system %{git add public/assets}
end
{% endhighlight %}

When you have the Git hook `.git/hooks/pre-commit` running `bundle exec rake`, you'll always be guaranteed to not only have correct code,
but also to have compiled assets.

### Annoying JavaScript, part 2

Just because you don't have a JavaScript runtime on the remote server doesn't mean you should turn off the asset pipeline on production.
You could have more _annoying JavaScript_ that you need to access. What you want to do is be careful not to include any CoffeeScript files
(and if it's an annoying JS project, trust me, they don't have any). and keep the pipeline on. Oh, and disable the JS compressor.
The stuff you care about compressing is already compressed from the operation above.

## End of guide.

Now get to coding super-fast using Rails 3.1, asset pipelines, and other fun things!

## History

* 0.9001: Hi, Scott.

