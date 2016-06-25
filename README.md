# GraphQL + Rails `@defer` / `@stream`

A demo of GraphQL's "exploratory" `@defer` and `@stream` directives with Ruby on Rails.

This uses a WIP branch of graphql-ruby: https://github.com/rmosolgo/graphql-ruby/compare/defer-directive

![stream-defer](https://cloud.githubusercontent.com/assets/2231765/16359345/b425e240-3afe-11e6-8cf2-33ea294d7e18.gif)

- Setup
  - install Ruby 2.2 or greater
  - `$ gem install bundler` (install Bundler, Ruby's package manager with)
  - `$ bundle install` (install this project's dependencies from `Gemfile`)
  - `$ bundle exec rake db:create db:seed` (setup the database and add seed data)
  - `$ bundle exec rails server` (start the development server)
  - `$ open http://localhost:3000/` (visit the app)
- ActionCable transports
  - Send GraphQL with ActionCable, Rails 5's new websocket library
  - `http://localhost:3000/action_cable_transport`
  - Server: [app/channels/graphql_channel.rb](https://github.com/rmosolgo/graphql-ruby-stream-defer-demo/blob/master/app/channels/graphql_channel.rb)
  - Client: [app/assets/javascripts/channels/graphql_channel.js](https://github.com/rmosolgo/graphql-ruby-stream-defer-demo/blob/master/app/assets/javascripts/channels/graphql_channel.js)
- `Transfer-Encoding: chunked` transport
  - Return `\n\n`-delimited chunks over a streaming HTTP response
  - `http://localhost:3000/chunked_transport`
  - Server: [app/controllers/chunked_graphqls_controller.rb](https://github.com/rmosolgo/graphql-ruby-stream-defer-demo/blob/master/app/controllers/chunked_graphqls_controller.rb)
  - Client: [app/assets/javascripts/graphql_fetch.js](https://github.com/rmosolgo/graphql-ruby-stream-defer-demo/blob/master/app/assets/javascripts/graphql_fetch.js)
