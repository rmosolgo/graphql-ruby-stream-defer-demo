class Post < ApplicationRecord
  after_commit :trigger_subscription

  def trigger_subscription
    GraphqlChannel::REGISTRY.trigger(:posts)
  end
end
