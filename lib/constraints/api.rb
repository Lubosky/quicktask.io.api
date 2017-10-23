module Constraints
  class API
    def initialize(options)
      @default = options[:default]
      @version = options[:version]
    end

    def matches?(request)
      default ||
        (request.respond_to?('headers') &&
         request.headers.key?('Accept') &&
         request.headers['Accept'].include?("application/vnd.gliderpath.v#{version}+json"))
    end

    private

    attr_reader :default, :version
  end
end
