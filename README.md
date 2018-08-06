# beforehand
WIP: fragment cache warming for Rails 4.2+

## Pitch:
Hate that first requests are slow before the results get cached?  
`beforehand` introduces a simple DSL (model callbacks on some steroids) where you define which template(s) to render in the background on record commit.

## Technology:
* Rails 4.2 for ActiveJob ecosystem
* https://rubygems.org/gems/backport_new_renderer gem from Rails5 for request-less rendering (see [the post](https://evilmartians.com/chronicles/new-feature-in-rails-5-render-views-outside-of-actions))
* Sidekiq as the job adapter
* Redis - configured to be dedicated to cache only, memory-limited, LRU-expiry.

## Use scenarios:
1. I have a `UsersController#index` action that renders 50 rows on each page. Each row represents a `User` model record. I want the rows to be cached.
2. I have a `header/partials/_total_revenue.html.erb` partial that renders a small table I put in every view's header. I does not represent any resource per-se. I want commits on any of revenue-generating models to fire a complete recalculation of the table and results to be cached.

## Design considerations:
1. Cache key managament is hard. What key can be generated in the callback? What keys does vanilla rails fragment caching generate? Gotta find a middle ground.
2. How and when to expire the cache?
 > * Cached records must expire if template or any of its subportions change. Feasable?  
 > * Cache must expire (or get overwritten) when the underlying record (if applicable) is updated
3. How to simplify renderable template parameter passing?
4. How to expose Sidekiq config to use (queue)?
5. How to enforce JSON-only API (no records passed, only ids and strings)?
6. How to optimize queueing by allowing only a single enqueuement with identical arguments (so-called unique-job)?
