# beforehand
WIP: fragment cache warming for Rails 4.2+

## Pitch:
Hate that first requests are slow before the results get cached?  
`beforehand` introduces a simple DSL (model callbacks on some steroids)
where you define which template(s) to render in the background and pre-cache.

## Technology requirements:
* Ruby 2.3.7+
* Rails 4.2.10+ for ActiveJob ecosystem
* [backport_new_renderer](https://rubygems.org/gems/backport_new_renderer) gem from Rails5 for request-less rendering (see [the post](https://evilmartians.com/chronicles/new-feature-in-rails-5-render-views-outside-of-actions))
* A __memory-limited, evicting__ cache store, `Redis` is recommended
* (optional, recommended) `Sidekiq` as the queue adapter

### Integration checklist

1. Have ActiveJob configured, preferrably with Sidekiq as the adapter
 > `config.active_job.queue_adapter = :sidekiq`
2. Have Rails.cache configured, preferably with Redis as the adapter
 > ```rb
 > # Pre Rails 5.2
 >   # in Gemfile
 >   gem "redis-rails", "~> 4.0"
 >   
 >   # in application.rb
 >   config.cache_store = :redis_store, "redis://127.0.0.1:6380"
 > 
 > # Rails 5.2
 > config.cache_store = :redis_cache_store, {url: "redis://127.0.0.1:6380"}
 > ```

* Try these settings for Redis:
 > ```
 > # must be of limited memory
 > maxmemory 300MB
 >
 > # must have an eviction policy, LRU is good for this
 > maxmemory-policy allkeys-lru
 > maxmemory-samples 4
 > ```
3. Have child records `touch` their parents 
4. Have the cache clear on every boot
5. Have caching-enabled view(s) using `beforehand`-flavored cache keys
6. Override the default [`cache`](https://github.com/rails/rails/blob/master/actionview/lib/action_view/helpers/cache_helper.rb) helper to always use the passed key as-is, not append the template digest.
 > ```rb
 > # in app/helpers/application_helper.rb
 > def cache(name = {}, options = {}, &block)
 >   options = {skip_digest: true}.merge(options)
 >   super
 > end
 > ```
7. Pass a truthy `ENV["CACHE_BEFOREHAND"]` option
   to processes you want to allow to enqueue after-init caching, usually your webserver (puma/unicorn) process, but not `sidekiq` and ad-hoc `rails c` calls.
8. Have `beforehand` callbacks configured
 - 5.1 Global configuration
 - 5.2 Model-specific configuration
   - 5.2.1 Method that will produce HTML and cache it
   - 5.2.2 `beforehand` callback that will invoke the method
 - 5.3 After-init configuration

## Design considerations:
1. __Q:__ How does this work?
 > __A:__ This library follows `'key based cache expiration'` paradigm, please read DHH's [post about it](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works).  
 > As such, using cache keys that can be generated from any context (view, model callback, job) and using them consistently is paramount.

2. __Q:__ But key managament is hard! Do I get any help?
 > __A:__ Yes!  
 > Use `Beforehand.cache_key(*records, **contexts)` method to generate the appropriate key from anywhere.
 > The order of arguments is irrelevant, there's sorting inside.  
 > You could also define a view helper that wraps that call for less typing.  

3. __Q:__ How do I begin?
 > __A:__ Good fragment caching with warming rests on three steps, each incrementally less important:  
  >  1. Basic caching in views with __keys that can be generated from any context__
  >  2. Resource re-caching after changes (via model callback)
  >  3. After-boot cache warmup (via `after-initialize` hook)
  >
  > Start with step 1 and introduce step 2 and 3 layers later.

4. __Q:__ How and when to expire the cache?
 > __A:__ Normally, key based caches are not expired, instead, they are allowed to fill up,
 > and the cache eviction policy (ideally LRU) to kick in.  
 > However, since it is possible for generated HTML to change without template or record having changed (for example, from changes in data passed from controller, config), production cache *must be expired* on every Rails boot. `beforehand` does not do this for you, so, please, add this to your `config/application.rb`
 > ```rb
 > config.after_initialize do
 >   if ENV["CACHE_BEFOREHAND"].present?
 >     Rails.logger.info("--> Clearing Rails cache after initialization")
 >     Rails.cache.clear
 >   end
 > end
 >```  
 > Beyond that, whatever options `Rails.cache.fetch` accepts, `beforehand` supports. There may be use-cases for specifying a key with expiry within 24 hours or somesuch.
 
5. __Q:__ What happens if a record gets updated several times in a short while?
 > __A:__ You are asking whether the sensible thing, namely, checking uniqueness and queueing only one job, will happen.  
 > Unfortunately, no. ActiveJob does not expose a backend-independent API for this, so `beforehand` can not support such behavior either.  
 > Luckily, `beforehand` does take steps to prevent [dogpile effect](https://www.sobstel.org/blog/preventing-dogpile-effect/) in the asynchronious warming part, so normally repeat jobs will merely take up queue space, but won't be actually doing anything once their turn comes. 
 > Please note that several parralel web-requests will totally dogpile the cache and there is little that can or should be done about it.

6. __Q:__ I have a `User` model with `has_many :posts` and `belongs_to :company`. How do I organize `beforehand`'s caching directives in my models?
 > __A:__ A model ought to define caching directives only for templates it itself is used in.  
 > In other words, ask "which views will change now that this record has changed?".    
 > In this case, `User` could define caching directives for `template: "/users/index/row"`, and `template: "/companies/show/users/row`, but leave `template: "/posts/show"` for the `Post` model to define.  
 > Try to keep things simple and fragment-cache only HTML that depends on data from a single resource.

7. __Q:__ How should I organize `beforehand` for changes in children to invalidate parent record cache?
 > __A:__ This is standart and Rails provides the `belongs_to :parent, touch: true` association option, configure it for models for whom your resource is a parent.

8. __Q:__ How should I organize `beforehand` for changes in parent to invalidate children record caches?
 > __A:__ Rails consciously does not provide a 'parent -> child' direction touch option. Instead, you should be including the relevant parent objects in the cache key. That way a new cache key is generated on parent updates without needing to update all children. Addmitedly this does put the burden on the developer to identify the parent objects used in cacheable fragments. Yet another reason to keep the fragments simple and single-resource.

## Use scenarios:
1. I have a `UsersController#index` action that renders 50 rows on each page. Each row represents a `User` model record. I want the rows to be cached and pre-heated.
 > Easy!
2. I have a `header/partials/_total_revenue.html.erb` partial that renders a small table I put in every view's header. I does not represent any resource per-se. I want commits on any of revenue-generating models to fire a complete recalculation of the table and results to be cached and pre-heated.
 > No problem! A static, time-expired cache key may be the way to go here.
3. I have a multi-language app and I want an index row partial to be cached and pre-heated
in a number of languages.
 > As do we! `beforehand` was developed with this use-case in mind.

4. I have an app where users can configure how things look for them, and I want a resource to be cached and pre-heated for each of them.
> No, just, no. If you have more than 50 unique users, this will get out of hand quick.  
> Alternative approaches are:  
> 1. Cache based on the user's setting, not their id (perhaps there are only two settings users can pick from, a light and dark layout, for example).  
> 2. Cache the resource data, not the HTML, sub-ideal performance-wise, but preserves sanity.

Please, take a look at the `spec` directory for more use-cases.

## Example config
There are three layers of config:
1. global - for defaults
2. model-specific - how to generate the HTML and where to put it
3. after-init - which records to pre-heat according to config in model

### 1. Global config
Make an initializer and place this inside

```rb
# in /config/initializers/beforehand.rb

Beforehand.configure do |c|
  # Set for how long you want background jobs to skip trying to fill the cache
  # once the firs job has started working
  # For example, generating the cache HTML takes 5s
  # The job1 starts generation at 12:00:00 and will finish at ~12:00:05
  # Job2 starts at 12:00:03. Since the cache is still empty, job2
  # would start generating the HTML alongside job1, resulting in dogpiling.
  # However, with the threshold in place, we can tell job2 to do nothing,
  # as job1 has this covered.
  # Furthermore, if generating has not finished in 20s (something gone wrong with job1),
  # another job will be able to take over from job1.
  c.anti_dogpile_threshold = 20 # as in 20s
  
  # Debugging flag
  # set to true to get messages in logs like this:
  # TODO
  c.verbose = false 
  
  # `.beforehand` method argument validation behavior
  # Defaults to true for strict and safe.
  # If you are doing some runtime metaprogramming magic, you may need to set this to false
  c.strict_beforehand_options = true
end
```

### 2. Model-specific config
This is the meat of the gem.  

 Please also take a look at the models in the test app in `spec/dummy`.  
```rb
class User < ActiveRecord::Base
  # ...

  after_commit :last_of_other_commits, on: :create   

  # Please, put the .beforehand macro after all your callbacks,
  # since it is an after_commit callback itself

  # Provided your caching-enabled view looks like this:
  # <% @users.each do |user| %>
  #   <% cache_key = Beforehand.cache_key(user, locale: I18n.locale, in: "users/index") %>

  #   <% cache(cache_key) do %>
  #     <%= render "users/index/row", user: user %>
  #   <% end %>
  # <% end %>

  SUPPORTED_LOCALES = ["en", "lv"].freeze

  SUPPORTED_LOCALES.each do |locale|
    # Define a callback for each locale variant to render
    beforehand(
      # when to preheat. Must specify at least one
      run: :on_callback,     
      # how to preheat     
      method: {
        name: :preheat_users_index_rows,
        # NB, to avoid serialization problems, *use JSON-compatible positional arg values only*!
        args: [locale]
      },
      job_options: {        
        queue: :precache,        
      },  
      callback_options: { # supports the same options after_commit does.
        on: :create 
      }
    )
    
    # define an after-init warming block
    beforehand(     
      run: :on_app_init,      
      init_options: {
        # Specify a calleable object (like a lambda) that will return which records to preheat on app init.
        # Be careful not to enqueue too much as it will slow things down for you         
        collection: -> { active.order(updated_at: :desc).first(50) },
        # specify an integer priority for order in which init preheating will be enqueued
        # lower means will be picked earlier. Defaults to 5.
        priority: 1 
      },
      # how to preheat     
      method: {
        name: :preheat_users_index_rows,
        # NB, to avoid serialization problems, *use JSON-compatible positional arg values only*!
        args: [locale]
      },
      job_options: {        
        queue: :low        
      }       
    )
  end  

  private
    # The actual method that will be invoked asynchroniously
    def preheat_users_index_rows(locale)
      cache_key = Beforehand.cache_key(self, locale: locale, in: "users/index")

      Rails.cache.fetch(cache_key) do
        
      end
    end
end
```

### 3. After-init hook config

```rb
# in /config/environments/production.rb
Rails.application.configure do
  # ...
  
  # For init preheating to work, models need to be read for the callback definition
  config.eager_load = true 
  # OR, If you do not want to eager_load everything,
  # calling the model to trigger code load will suffice
  User

  config.cache_classes = true 

  config.after_initialize do
    if ENV["CACHE_BEFOREHAND"].present?
      Rails.logger.info("--> Enqueuing records for pre-heating")
      Beforehand.enqueue
    end
  end
end
```

## Developing the gem
This is an open-source project, you are welcome to participate in its development.

1. Fork the repo and clone it on your machine
2. Make sure you have appropriate Ruby and Postgres (any DB driver should do, but you gota swap out the gem and db config then) versions.
3. Make existing tests run
> ```rb
> $ bundle
> $ rake db:create RAILS_ENV=test
> $ rspec
>``` 
4. [TDD](https://en.wikipedia.org/wiki/Test-driven_development) a new feature
5. Open a Pull Request from your feature branch to this project's master branch.

### Feature roadmap
- [] Support for verbose debugging mode
- [] `.beforehand` method accepts callback options
- [] Can preheat single records in a single locale
- [] Can preheat a single record in multiple locales
- [] Cache job guards against dogpiling
- [] Only enqueue init jobs once even when running several independent worker processes (puma spec)


