# beforehand
WIP: fragment cache warming for Rails 4.2+

## Pitch:
Hate that first requests are slow before the results get cached?  
`beforehand` introduces a simple DSL (model callbacks on some steroids) where you define which template(s) to render in the background and pre-cache.

## Technology:
* Ruby 2.3.4+
* Rails 4.2+ for ActiveJob ecosystem
* [backport_new_rendere](https://rubygems.org/gems/backport_new_renderer) gem from Rails5 for request-less rendering (see [the post](https://evilmartians.com/chronicles/new-feature-in-rails-5-render-views-outside-of-actions))

## Use scenarios:
1. I have a `UsersController#index` action that renders 50 rows on each page. Each row represents a `User` model record. I want the rows to be cached and pre-heated.
2. I have a `header/partials/_total_revenue.html.erb` partial that renders a small table I put in every view's header. I does not represent any resource per-se. I want commits on any of revenue-generating models to fire a complete recalculation of the table and results to be cached and pre-heated.

## Design considerations:
1. Q: Cache key managament is hard. What key can be generated in the callback? What keys to use in view templates?
 > A: Vanilla Rails view cache keys are inadequate, use the built-in `Beforehand.cache_key(*records, **contexts)` method call
2. Q: How and when to expire the cache?
 > A: Since it is possible for generated HTML to change without template or record having changed (for example, from changes in data passed from controller, config), production cache *must be expired* on every Rails boot. Beyond that, whatever options `Rails.cache.fetch` accepts, `beforehand` supports.
 
 *
* Redis - configured to be dedicated to cache only - memory-limited, LRU-expiry.

3. How to simplify renderable template parameter passing?
4. How to expose Sidekiq config to use (queue)?
5. How to enforce JSON-only API (no records passed, only ids and strings)?
6. How to optimize queueing by allowing only a single enqueuement with identical arguments (so-called unique-job)?
