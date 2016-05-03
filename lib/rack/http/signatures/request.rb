require 'rack/auth/abstract/request'
require 'rack/http/signatures/key_manager'
require 'rack/http/signatures/verifier'
require 'rack/http/signatures/ciphers/rsa256'
require 'rack/http/signatures/errors/unknown_algorithm_error'
require 'base64'

module Rack::Http::Signatures
  class Request < Rack::Auth::AbstractRequest
    def parameters
      @parameters ||= SignatureParametersParser.parse(params)
    end

    def key_id
      parameters['keyId']
    end

    def valid?
      return false unless signature?

      Verifier.verify(
          parameters['algorithm'],
          KeyManager.get_key_from_keyid(key_id),
          parameters['signature'],
          get_data(parameters['headers'])
      )
    rescue Errors::UnknownAlgorithmError, TypeError
      false
    end

    def signature?
      return false if (@env.keys & AUTHORIZATION_KEYS).empty?
      'signature' == scheme
    end

    private

    def get_data(headers)
      (headers || 'date').split(' ').map do |header|
        return "#{header}: #{@env['REQUEST_METHOD'].downcase} #{@env['REQUEST_PATH']}" if header == '(request-target)'
        "#{header}: #{@env["HTTP_#{header.upcase}"]}"
      end.join("\n")
    end
  end
end
