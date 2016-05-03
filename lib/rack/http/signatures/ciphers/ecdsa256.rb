require 'openssl'

module Rack::Http::Signatures::Ciphers
  module ECDSA256
    class << self
      DIGEST = OpenSSL::Digest::SHA256.new

      def verify(key, signature, data)
        public_key = OpenSSL::PKey::EC.new(key)
        public_key.verify(DIGEST, signature, data)
      rescue OpenSSL::PKey::PKeyError
        false
      end
    end
  end
end
