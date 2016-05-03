require 'rack/http/signatures/key_manager'

module Rack::Http::Signatures
  class Config < Hash
    def get_key_from_keyid(&block)
      KeyManager.send :define_singleton_method, :get_key_from_keyid, &block
    end
  end
end
