require 'rack/http/signatures/errors/signature_parameters_parser_error'

module Rack::Http::Signatures
  module SignatureParametersParser
    class << self
      def parse(string)
        Hash[array_of_pairs(string)]
      end

      private

      def array_of_pairs(string)
        segments(string).map { |segment| pair(segment) }
      end

      def segments(string)
        string.split(',')
      end

      def pair(segment)
        match = segment_pattern.match(segment)
        raise Errors::SignatureParametersParserError, "unparseable segment: #{segment}" if match.nil?
        match.captures
      end

      def segment_pattern
        %r{\A(keyId|algorithm|headers|signature)="(.*)"\z}
      end
    end
  end
end
