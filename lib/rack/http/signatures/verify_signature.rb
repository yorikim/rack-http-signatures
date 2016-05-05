require 'rack/http/signatures/request'
require 'rack/http/signatures/config'
require 'rack/http/signatures/request_validator'

module Rack::Http::Signatures
  class VerifySignature
    def initialize(app)
      @app, @config = app, Config.new
      yield @config if block_given?
    end

    def call(env)
      RequestValidator.validate_request(Request.new(env))

      @app.call(env)
    rescue RequestValidator::BadRequestError => e
      bad_request(e.message)
    rescue RequestValidator::UnauthorizedError => e
      unauthorized(e.message)
    end

    private

    def bad_request(message)
      [400,
       {'Content-Type' => 'text/plain',
        'Content-Length' => "#{message.size}",
       },
       [message]
      ]
    end

    def unauthorized(message)
      [401,
       {'Content-Type' => 'text/plain',
        'Content-Length' => "#{message.size}",
        'WWW-Authenticate' => challenge},
       [message]
      ]
    end

    def realm
      @config[:realm]
    end

    def challenge
      "Signature realm=\"#{realm}\",headers=\"(request-target) date\""
    end
  end
end
