class GraphqlChannel <  ApplicationCable::Channel
  def subscribed
    stream_from(channel_name)
  end

  def fetch(data)
    query_id = data["query_id"]
    query_string = data["query"]
    variables = ensure_hash(data["variables"] || {})
    context = {}

    # This object emits patches
    context[:collector] = GraphQL::Streaming::ActionCableCollector.new(query_id, ActionCable.server.broadcaster_for(channel_name))

    # This re-evals the query in response to triggers
    context[:subscriber] = GraphQL::Streaming::ActionCableSubscriber.new(self, query_id) do
      Schema.execute(query_string, variables: variables, context: context)
    end

    Schema.execute(query_string, variables: variables, context: context)

    # If there are no ongoing subscriptions,
    # tell the client to stop listening for patches
    if !context[:subscriber].subscribed?
      context[:collector].close
    end
  rescue StandardError => err
    puts "--- FETCH ---"
    raise err
  end

  private

  def ensure_hash(hashy_param)
    case hashy_param
    when String
      JSON.parse(hashy_param)
    when Hash
      hashy_param
    else
      {}
    end
  end

  def channel_name
    "graphql_#{current_user}"
  end
end
