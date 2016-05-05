require 'rack/auth/abstract/request'
require 'rack/http/signatures/key_manager'
require 'rack/http/signatures/signature_parameters_parser'
require 'base64'

module Rack::Http::Signatures
  class Request < Rack::Auth::AbstractRequest
    def parameters
      @parameters ||= SignatureParametersParser.parse(params)
    rescue SignatureParametersParser::SignatureParametersParserError
      @parameters ||= nil
    end

    def key_id
      parameters['keyId']
    end

    def algorithm
      parameters['algorithm']
    end

    def signature
      parameters['signature']
    end

    def public_key
      @key ||= KeyManager.send "public_#{algorithm.gsub('-', '_')}_key_from_keyid", key_id
    rescue NoMethodError
      @key ||= nil
    end

    def signed_data
      @signed_data ||= (parameters['headers'] || 'date').split(' ').map do |header|
        return "#{header}: #{@env['REQUEST_METHOD'].downcase} #{@env['REQUEST_PATH']}" if header == '(request-target)'
        "#{header}: #{@env["HTTP_#{header.upcase}"]}"
      end.join("\n")
    end

    def valid_parameters?
      parameters && signature? && signature
    end

    def valid_algorithm?
      @valid_algorithm ||= CipherFactory::VALID_ALGORITHMS.include?(algorithm)
    end

    def signature?
      return false if (@env.keys & AUTHORIZATION_KEYS).empty?
      'signature' == scheme
    end
  end
end
