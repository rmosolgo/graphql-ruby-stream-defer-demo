class GraphqlsController < ApplicationController
  def create
    query_string = params[:query]
    variables = ensure_hash(params[:variables] || {})
    context = {}
    result = Schema.execute(query_string, variables: variables, context: context)
    render json: result
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
