require 'spec_helper'
require 'rack/mock'

describe Rack::Http::Signatures::VerifySignature do
  let(:app) { lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] } }

  subject do
    described_class.new(app) do |config|
      config.get_key_from_keyid { |key_id| File.read('spec/support/fixtures/public.pem') }
    end
  end

  context 'with Authorization header' do
    let(:request) { Rack::MockRequest.new(subject) }

    it 'returns 401 when set unknown algorithm' do
      response = request.get('/', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="Unknown-algorithm",headers="date",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="')
      expect(response.status).to eq(401)
    end

    context 'with headers field' do
      it 'returns success code' do
        response = request.get('/', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="rsa-sha256",headers="date",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="')
        expect(response.status).to eq(200)
      end

      it 'returns 401 code' do
        response = request.get('/', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="rsa-sha256",headers="date",signature=""')
        expect(response.status).to eq(401)
      end
    end

    context 'without headers field' do
      it 'returns success code' do
        response = request.get('/', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="rsa-sha256",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="')
        expect(response.status).to eq(200)
      end

      it 'returns 401 code' do
        response = request.get('/', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="rsa-sha256",signature=""')
        expect(response.status).to eq(401)
      end
    end
  end
end
