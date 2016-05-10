require 'openssl'
require 'base64'
require 'rack/http/signatures/digest'

module Rack
  module Http
    module Signatures
      class DigestValidator
        class << self
          def valid?(body, digest_header)
            digest = Digest.from_string(digest_header)
            return false unless digest.valid_algorithm?

            sha256 = OpenSSL::Digest::SHA256.new
            sha256 << body
            sha256.digest == digest.body
          end
        end
      end
    end
  end
end
