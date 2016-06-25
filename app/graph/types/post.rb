Types::Post = GraphQL::ObjectType.define do
  name "Post"
  field :id, types.Int
  field :title, types.String
  field :body, types.String do
    resolve -> (obj, args, ctx) {
      sleep 0.5
      obj.body
    }
  end
  field :posts, -> { types[Types::Post] } do
    resolve -> (obj, args, ctx) {
      Enumerator.new do |yielder|
        posts = Post.all
        posts.each do |post|
          sleep 0.5
          yielder.yield(post)
        end
      end
    }
  end
end
