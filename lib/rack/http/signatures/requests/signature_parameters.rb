module Rack
  module Http
    module Signatures
      module SignatureParameters
        def parameters
          @parameters ||= SignatureParametersParser.parse(params)
        rescue SignatureParametersParser::SignatureParametersParserError
          @parameters ||= nil
        end

        def key_id
          parameters['keyId']
        end

        def algorithm
          parameters['algorithm']
        end

        def signature
          parameters['signature']
        end

        def public_key
          @key ||= KeyManager.send "public_#{algorithm.tr('-', '_')}_key_from_keyid", key_id
        rescue NoMethodError
          @key ||= nil
        end

        def signed_data
          @signed_data ||= (parameters['headers'] || 'date').split(' ').map { |header| signed_header(header) }.join("\n")
        end

        protected

        def signed_header(header)
          case header
          when '(request-target)' then
            "#{header}: #{method.downcase} #{relative_path}"
          when 'host' then
            "#{header}: #{host}"
          when 'content-length' then
            "#{header}: #{content_length}"
          else
            "#{header}: #{@env["HTTP_#{header.tr('-', '_').upcase}"]}"
          end
        end
      end
    end
  end
end
