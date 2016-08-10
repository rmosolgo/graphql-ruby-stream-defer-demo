App.graphqlChannel = App.cable.subscriptions.create(
  "GraphqlChannel",
  Object.assign(GraphQLChannel.subscription, {
    connected: function() {
      $(document).trigger("graphql-channel:ready")
    },
  })
)

// forward logs to console.log
GraphQLChannel.log = console.log.bind(console)
