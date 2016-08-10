Schema = GraphQL::Schema.new(
  query: Types::Query,
  subscription: Types::Subscription,
)

Schema.query_execution_strategy = GraphQL::Execution::DeferredExecution
Schema.subscription_execution_strategy = GraphQL::Execution::DeferredExecution
