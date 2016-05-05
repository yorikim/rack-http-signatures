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
        case header
          when '(request-target)' then
            "#{header}: #{method.downcase} #{relative_path}"
          when 'host' then
            "#{header}: #{host}"
          when 'content-length' then
            "#{header}: #{content_length}"
          else
            "#{header}: #{@env["HTTP_#{header.gsub('-', '_').upcase}"]}"
        end
      end.join("\n")
    end

    def body
      @env['rack.input']
    end

    def query_string
      @env['QUERY_STRING']
    end

    def script_name
      @env['SCRIPT_NAME']
    end

    def path_info
      @env['PATH_INFO']
    end

    def relative_path
      query_string.empty? ? path_info : "#{path_info}?#{query_string}"
    end

    def host
      @env['SERVER_NAME']
    end

    def content_length
      @env['CONTENT_LENGTH']
    end

    def method
      @env['REQUEST_METHOD']
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
