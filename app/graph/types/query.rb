Types::Query = GraphQL::ObjectType.define do
  name "Query"
  field :echo, types.Int, "Return the same value passed as 'int'" do
    argument :int, !types.Int
    resolve -> (obj, args, ctx) { args[:int] }
  end
  field :posts, types[Types::Post] do
    resolve -> (obj, args, ctx) { Post.all }
  end
end
