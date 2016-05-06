require 'base64'
require 'rack/http/signatures/digest'

module Rack::Http::Signatures
  class DigestValidator
    class << self
      SHA256 = OpenSSL::Digest::SHA256.new

      def valid?(body, digest_header)
        digest = Digest.from_string(digest_header)
        return false unless digest.valid_algorithm?

        SHA256.reset
        SHA256 << body
        SHA256.digest == digest.body
      end
    end
  end
end
