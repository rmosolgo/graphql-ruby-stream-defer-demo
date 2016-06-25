class GraphqlChannel <  ApplicationCable::Channel
  def subscribed
    stream_from(channel_name)
  end

  def fetch(data)
    query_id = data["query_id"]
    query_string = data["query"]
    variables = ensure_hash(data["variables"] || {})
    # This object emits patches
    collector = GraphQLCollector.new(query_id, channel_name)
    context = {
      subscriber: GraphQLSubscriber.new(self, query_id, query_string),
      collector: collector
    }
    result = Schema.execute(query_string, variables: variables, context: context)
    if !collector.patched?
      payload = {
        result: result,
        query_id: query_id,
      }
      ActionCable.server.broadcast(channel_name, payload)
    end
  rescue StandardError => err
    puts "--- FETCH ---"
    puts err
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

  class GraphQLRegistry
    def trigger(pubsub_handle)
      ActionCable.server.broadcast("graphql_subscription_#{pubsub_handle}", {})
    end
  end

  REGISTRY = GraphQLRegistry.new

  class GraphQLCollector
    def initialize(query_id, channel_name)
      @query_id = query_id
      @channel_name = channel_name
      @was_patched = false
    end

    def patch(path:, value:)
      @was_patched = true
      payload = {
        patch: {
          path: path,
          value: value,
        },
        query_id: @query_id,
      }
      ActionCable.server.broadcast(@channel_name, payload)
    end

    def patched?
      @was_patched
    end
  end

  class GraphQLSubscriber
    def initialize(channel, query_id, query_string)
      @channel = channel
      @query_id = query_id
      @query_string = query_string
    end

    def register(pubsub_handle)
      @channel.stream_from("graphql_subscription_#{pubsub_handle}") do |message|
        begin
          puts "SUBSCRIPTION EXEC => #{pubsub_handle}"
          result = Schema.execute(@query_string, variables: {})
          payload = {
            result: result,
            query_id: @query_id,
          }
          # TODO: any option other than this hack?
          @channel.send(:transmit, payload)
        rescue StandardError => err
          puts "--- TRANSMIT ---"
          puts err
        end
      end
    rescue StandardError => err
      puts "--- REGISTER ---"
      puts err
    end
  end
end
