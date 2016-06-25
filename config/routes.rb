Rails.application.routes.draw do
  root to: redirect("/home")
  resource :home, only: :show
  resource :action_cable_transport, only: :show
  resource :chunked_transport, only: :show
  resource :chunked_graphql, only: :create

  resources :posts
  resource :graphql, only: :create
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
end
