require 'openssl'
require 'base64'

module Rack
  module Http
    module Signatures
      module Ciphers
        module RSA256
          class << self
            DIGEST = OpenSSL::Digest::SHA256.new

            def verify(key, signature, data)
              public_key = OpenSSL::PKey::RSA.new(key)
              public_key.verify(OpenSSL::Digest::SHA256.new, signature, data)
            end
          end
        end
      end
    end
  end
end
