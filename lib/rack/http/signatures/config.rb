require 'rack/http/signatures/key_manager'

module Rack::Http::Signatures
  class Config < Hash
    ALGORITHMS = %w(rsa_sha256 hmac_sha256)

    def method_missing(method, *args, &block)
      match_data = /public_(.*)_key_from_keyid/.match(method)
      if match_data && ALGORITHMS.include?(match_data[1])
        KeyManager.send :define_singleton_method, method, &block
      else
        super
      end
    end
  end
end
