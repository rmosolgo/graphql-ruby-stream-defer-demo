class Post < ApplicationRecord
  after_commit :trigger_subscription

  def trigger_subscription
    GraphQL::Streaming::ActionCableSubscriber.trigger(:post, {id: id})
  end

  DEFAULT_QUERY_STRING = "{
  posts @stream {
    title
    body @defer
  }
}"

  SUBSCRIPTION_QUERY_STRING = "subscription {
  post(id: 1) {
    title
    body
  }
}"
end
