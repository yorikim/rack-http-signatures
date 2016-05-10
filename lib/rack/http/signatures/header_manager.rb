module Rack
  module Http
    module Signatures
      class HeaderManager
        class << self
          def authorization_header
            'Authorization'
          end

          def digest_header
            'Digest'
          end
        end
      end
    end
  end
end
