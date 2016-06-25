module Types
  # Wrap resolve_proc with subscription registration logic
  def self.subscribes_as(pubsub_handle, resolve_proc)
    -> (obj, args, ctx) {
      subscriber = ctx[:subscriber]
      subscriber && subscriber.register(pubsub_handle)
      resolve_proc.call(obj, args, ctx)
    }
  end

  Subscription = GraphQL::ObjectType.define do
    name "Subscription"
    field :observe_posts, types[Types::Post] do
      resolve Types.subscribes_as :posts, -> (obj, args, ctx) {
        p "SUBS"
        ::Post.all
      }
    end
  end
end
