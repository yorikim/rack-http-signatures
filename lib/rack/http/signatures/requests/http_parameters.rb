module Rack
  module Http
    module Signatures
      module HttpParameters
        def body
          @env['rack.input'].read
        end

        def digest
          @env['HTTP_DIGEST']
        end

        def query_string
          @env['QUERY_STRING']
        end

        def script_name
          @env['SCRIPT_NAME']
        end

        def path_info
          @env['PATH_INFO']
        end

        def relative_path
          query_string.empty? ? path_info : "#{path_info}?#{query_string}"
        end

        def host
          @env['SERVER_NAME']
        end

        def content_length
          @env['CONTENT_LENGTH']
        end

        def method
          @env['REQUEST_METHOD']
        end
      end
    end
  end
end
