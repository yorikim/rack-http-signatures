module Rack::Http::Signatures::Ciphers
  module HS256
    class << self
      def verify(key, signature, data)
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data) == signature
      end
    end
  end
end
