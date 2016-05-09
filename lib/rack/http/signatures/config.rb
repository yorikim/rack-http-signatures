require 'rack/http/signatures/cipher_factory'

module Rack
  module Http
    module Signatures
      class Config < Hash
        def method_missing(method, *args, &block)
          match_data = /public_(.*)_key_from_keyid/.match(method)
          if match_data && algorithms.include?(match_data[1])
            KeyManager.send :define_singleton_method, method, &block
          else
            super
          end
        end

        def bad_request(&block)
          VerifySignature.send :define_method, :bad_request, &block
        end

        def unauthorized(&block)
          VerifySignature.send :define_method, :unauthorized, &block
        end

        private

        def algorithms
          CipherFactory::VALID_ALGORITHMS.map { |algorithm| algorithm.tr('-', '_') }
        end
      end
    end
  end
end
