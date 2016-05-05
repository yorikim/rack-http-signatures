module Rack::Http::Signatures
  class RequestValidator
    BadRequestError = Class.new(StandardError)
    UnauthorizedError = Class.new(StandardError)

    class << self
      def validate_request(request)
        raise BadRequestError, 'authorization header not found' unless request.provided?
        raise BadRequestError, 'invalid parameters' unless request.valid_parameters?
        raise BadRequestError, 'algorithm not supported' unless request.valid_algorithm?
        raise UnauthorizedError, 'public key not found' unless request.public_key
        raise UnauthorizedError, 'signing failed' unless valid_signature?(request)
      end

      private

      def valid_signature?(request)
        return false unless request.public_key
        CipherFactory.create(request.algorithm).verify(request.public_key, Base64.decode64(request.signature), request.signed_data)
      end
    end
  end
end
