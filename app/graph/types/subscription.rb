module Types
  Subscription = GraphQL::ObjectType.define do
    name "Subscription"

    subscription :post, Types::Post do
      argument :id, !types.Int
      resolve -> (obj, args, ctx) {
        ::Post.find(args[:id])
      }
    end
  end
end
