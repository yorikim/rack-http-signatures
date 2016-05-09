require 'openssl'

module Rack
  module Http
    module Signatures
      module Ciphers
        module HS256
          class << self
            DIGEST = OpenSSL::Digest::SHA256.new

            def verify(key, signature, data)
              OpenSSL::HMAC.hexdigest(DIGEST, key, data) == signature
            end
          end
        end
      end
    end
  end
end
