require 'spec_helper'
require 'rack/mock'

describe Rack::Http::Signatures::VerifySignature do
  let(:app) { lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] } }

  subject do
    described_class.new(app) do |config|
      config.public_rsa_sha256_key_from_keyid { |key_id| File.read('spec/support/fixtures/rsa256/public.pem') if key_id == 'Test' }
      config.public_hmac_sha256_key_from_keyid { |key_id| File.read('spec/support/fixtures/hs256/key.txt') if key_id == 'Test' }
      config.public_ecdsa_sha256_key_from_keyid { |key_id| File.read('spec/support/fixtures/ecdsa256/public.pem') if key_id == 'Test' }
    end
  end

  context 'with Authorization header' do
    let(:http_headers) { {'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT'} }
    let(:request) { Rack::MockRequest.new(subject) }

    it 'returns 401 when set unknown algorithm' do
      response = request.get('/', http_headers.merge('HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="Unknown-algorithm",headers="date",signature="some signature"'))
      expect(response.status).to eq(401)
    end

    {:'rsa-sha256' => 'jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w=',
     :'hmac-sha256' => 'NzU4ZDAyMGRmNzQxZmQ3NDQ0YWY0Mzk5Y2YxMjUzYzA1NGI2MWQ2OTc5NjhlYjM3NTg2Y2I1MmFiMDlkN2NkNA==',
     :'ecdsa-sha256' => 'MEUCIQCoUjhsQ3pdTJvWwvWPfaBXsaR01Y90XYeOW1esCgHcggIgMAsJ8Xzln3JC6wk3ePn1dxz8jHF8WFOCL0Dkwub8/sw='
    }.each do |algorithm, signature|
      context 'with headers field' do

        it 'returns success code when keyId is valid' do
          response = request.get('/', http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",algorithm=\"#{algorithm}\",headers=\"date\",signature=\"#{signature}\""))
          expect(response.status).to eq(200)
        end

        it 'returns 401 code when keyId is invalid' do
          response = request.get('/', http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test1\",algorithm=\"#{algorithm}\",headers=\"date\",signature=\"\""))
          expect(response.status).to eq(401)
        end
      end

      context 'without headers field' do
        it 'returns success code when signature is valid' do
          response = request.get('/', http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",algorithm=\"#{algorithm}\",signature=\"#{signature}\""))
          expect(response.status).to eq(200)
        end

        it 'returns 401 code when signature is invalid' do
          response = request.get('/', http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",algorithm=\"#{algorithm}\",signature=\"\""))
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
