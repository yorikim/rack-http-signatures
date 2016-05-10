require 'rack/auth/abstract/request'
require 'rack/http/signatures/digest_validator'
require 'rack/http/signatures/header_manager'
require 'rack/http/signatures/requests/http_parameters'
require 'rack/http/signatures/requests/signature_parameters'
require 'rack/http/signatures/key_manager'
require 'rack/http/signatures/signature_parameters_parser'
require 'base64'
require 'openssl'

module Rack
  module Http
    module Signatures
      class Request < Rack::Auth::AbstractRequest
        include SignatureParameters
        include HttpParameters

        AUTHORIZATION_KEYS = ["HTTP_#{HeaderManager.authorization_header.upcase}"].freeze

        def valid_parameters?
          parameters && signature? && signature
        end

        def valid_algorithm?
          @valid_algorithm ||= CipherFactory::VALID_ALGORITHMS.include?(algorithm)
        end

        def valid_digest?
          @valid_digest ||= (digest.nil? || DigestValidator.valid?(body, digest))
        end

        def signature?
          return false if (@env.keys & AUTHORIZATION_KEYS).empty?
          'signature' == scheme
        end
      end
    end
  end
end
