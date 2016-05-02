require 'rack/http/signatures/signature_parameters_parser'
require 'rack/http/signatures/request'
require 'rack/http/signatures/config'

module Rack::Http::Signatures
  class VerifySignature
    def initialize(app)
      @app, @config = app, Config.new
      yield @config if block_given?
    end

    def call(env)
      @request = Request.new(env)
      return unauthorized unless @request.valid?

      @app.call(env)
    end

    private

    def unauthorized
      [401,
       {'Content-Type' => 'text/plain',
        'Content-Length' => '0',
        'WWW-Authenticate' => challenge},
       []
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
