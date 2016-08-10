class ChunkedGraphqlsController < ApplicationController
  include ActionController::Live

  def create
    query_string = params[:query]
    variables = ensure_hash(params[:variables] || {})
    context = {
      collector: GraphQL::Streaming::StreamCollector.new(response.stream)
    }
    Schema.execute(query_string, variables: variables, context: context)
    response.stream.close
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
end
