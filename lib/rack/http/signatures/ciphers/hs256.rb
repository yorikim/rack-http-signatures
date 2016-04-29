module Rack::Http::Signatures::Ciphers
  module HS256
    class << self
      def sign(key, data)
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, data)
      end
    end
  end
end
