module JSONAPI
  class ExceptionsHandler
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue JSON::ParserError, JSONAPI::Parser::InvalidDocument => exception
      content_type = 'application/json'
      status = 400
      error = {
        status: status,
        title: exception.class.name,
        detail: exception.to_s
      }
      render(status, content_type, JSON.dump(errors: [error]))
    end

    private

    def render(status, content_type, body)
      [status, { 'Content-Type' => content_type.to_s,
                 'Content-Length' => body.bytesize.to_s }, [body]]
    end
  end
end
