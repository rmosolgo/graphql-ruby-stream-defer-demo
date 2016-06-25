class ChunkedGraphqlsController < ApplicationController
  include ActionController::Live

  def create
    query_string = params[:query]
    variables = ensure_hash(params[:variables] || {})
    context = {
      collector: StreamCollector.new(response.stream)
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

  # Send patches by calling `stream.write`
  # Each patch is serialized as JSON and delimited with "\n\n"
  class StreamCollector
    def initialize(stream)
      @stream = stream
      @delimiter = ""
    end

    def patch(path:, value:)
      patch_string = {path: path, value: value}.to_json
      @stream.write @delimiter + patch_string
      # Use this delimiter for all patches after the first
      @delimiter = "\n\n"
    end
  end
end
