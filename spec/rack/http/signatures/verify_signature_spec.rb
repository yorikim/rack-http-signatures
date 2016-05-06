require 'spec_helper'
require 'rack/mock'

describe Rack::Http::Signatures::VerifySignature do
  let(:app) { lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] } }

  context 'with Authorization header' do
    subject do
      described_class.new(app) do |config|
        config.public_rsa_sha256_key_from_keyid { |key_id| File.read('spec/support/fixtures/rsa256/public.pem') if key_id == 'Test' }
        config.public_hmac_sha256_key_from_keyid { |key_id| File.read('spec/support/fixtures/hs256/key.txt') if key_id == 'Test' }
      end
    end

    let(:request) { Rack::MockRequest.new(subject) }
    let(:request_path) { 'http://example.com/foo?param=value&pet=dog' }
    let(:http_headers) { {
        input: '{"hello": "world"}',
        'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT',
        'HTTP_CONTENT_TYPE' => 'application/json',
        'HTTP_DIGEST' => 'SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=',
    } }

    it 'returns 400 when request without authorization header' do
      response = request.post(request_path, http_headers)
      expect(response.status).to eq(400)
      expect(response.body).to eq('authorization header not found')
    end

    it 'returns 400 when set unknown algorithm' do
      response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="Unknown-algorithm",headers="date",signature="some signature"'))
      expect(response.status).to eq(400)
      expect(response.body).to eq('algorithm not supported')
    end

    it 'returns 400 when set unknown field' do
      response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => 'Signature field="asdf",keyId="Test",algorithm="Unknown-algorithm",headers="date",signature="some signature"'))
      expect(response.status).to eq(400)
      expect(response.body).to eq('invalid parameters')
    end

    context 'check digest header' do
      let(:valid_http_signature) { http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",algorithm=\"rsa-sha256\",signature=\"jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w=\"") }

      it 'returns 400 when signature is invalid' do
        http_headers['HTTP_DIGEST'] = 'SHA-256=INVALID='
        response = request.post(request_path, valid_http_signature)
        expect(response.status).to eq(400)
        expect(response.body).to eq('digest header is not valid')
      end

      it 'returns 400 when algorithm is invalid' do
        http_headers['HTTP_DIGEST'] = 'SHA1=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE='
        response = request.post(request_path, valid_http_signature)
        expect(response.status).to eq(400)
        expect(response.body).to eq('digest header is not valid')
      end

      it 'returns 200 when digest header is empty' do
        http_headers.delete('HTTP_DIGEST')
        response = request.post(request_path, valid_http_signature)
        expect(response.status).to eq(200)
      end
    end


    context 'default test (no headers)' do
      {:'rsa-sha256' => 'jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w=',
       :'hmac-sha256' => 'NzU4ZDAyMGRmNzQxZmQ3NDQ0YWY0Mzk5Y2YxMjUzYzA1NGI2MWQ2OTc5NjhlYjM3NTg2Y2I1MmFiMDlkN2NkNA=='
      }.each do |algorithm, signature|
        context "using #{algorithm}" do
          it 'returns success code when signature is valid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",algorithm=\"#{algorithm}\",signature=\"#{signature}\""))
            expect(response.status).to eq(200)
          end

          it 'returns 401 code when keyId is invalid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test1\",algorithm=\"#{algorithm}\",signature=\"\""))
            expect(response.status).to eq(401)
            expect(response.body).to eq('public key not found')
          end

          it 'returns 401 code when signature is invalid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",algorithm=\"#{algorithm}\",signature=\"\""))
            expect(response.status).to eq(401)
            expect(response.body).to eq('signing failed')
          end
        end
      end
    end

    context 'basic test (minimum recommended data)' do
      {:'rsa-sha256' => 'HUxc9BS3P/kPhSmJo+0pQ4IsCo007vkv6bUm4Qehrx+B1Eo4Mq5/6KylET72ZpMUS80XvjlOPjKzxfeTQj4DiKbAzwJAb4HX3qX6obQTa00/qPDXlMepD2JtTw33yNnm/0xV7fQuvILN/ys+378Ysi082+4xBQFwvhNvSoVsGv4=',
       :'hmac-sha256' => 'NzE5Y2VhMTU0OGY3YmJkNWMxNWU3YmMyZTY3Njk5ZTJmMDU4MWE3NjRkYmVlMWRmYTJlZWIyMTY5MTY2NWZlMg=='
      }.each do |algorithm, signature|
        let(:header_field) { 'headers="(request-target) host date"' }

        context "using #{algorithm}" do
          it 'returns success code when signature is valid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",#{header_field},algorithm=\"#{algorithm}\",signature=\"#{signature}\""))
            expect(response.status).to eq(200)
          end

          it 'returns 401 code when keyId is invalid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test1\",#{header_field},algorithm=\"#{algorithm}\",signature=\"\""))
            expect(response.status).to eq(401)
            expect(response.body).to eq('public key not found')
          end

          it 'returns 401 code when signature is invalid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",#{header_field},algorithm=\"#{algorithm}\",signature=\"\""))
            expect(response.status).to eq(401)
            expect(response.body).to eq('signing failed')
          end
        end
      end
    end

    context 'all headers test (all of the headers and a digest of the body)' do
      {:'rsa-sha256' => 'Ef7MlxLXoBovhil3AlyjtBwAL9g4TN3tibLj7uuNB3CROat/9KaeQ4hW2NiJ+pZ6HQEOx9vYZAyi+7cmIkmJszJCut5kQLAwuX+Ms/mUFvpKlSo9StS2bMXDBNjOh4Auj774GFj4gwjS+3NhFeoqyr/MuN6HsEnkvn6zdgfE2i0=',
       :'hmac-sha256' => 'M2Q2ODg4ZDU4ZjAxODgyNWJlMjY1ZmI3YTg2NWM2Nzc1ZDA5MzhiMWRkOTk3MzJkMGZmMWVjY2U0YmNmNDFiMA=='
      }.each do |algorithm, signature|
        let(:header_field) { 'headers="(request-target) host date content-type digest content-length"' }

        context "using #{algorithm}" do
          it 'returns success code when signature is valid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",#{header_field},algorithm=\"#{algorithm}\",signature=\"#{signature}\""))
            expect(response.status).to eq(200)
          end

          it 'returns 401 code when keyId is invalid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test1\",#{header_field},algorithm=\"#{algorithm}\",signature=\"\""))
            expect(response.status).to eq(401)
            expect(response.body).to eq('public key not found')
          end

          it 'returns 401 code when signature is invalid' do
            response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => "Signature keyId=\"Test\",#{header_field},algorithm=\"#{algorithm}\",signature=\"\""))
            expect(response.status).to eq(401)
            expect(response.body).to eq('signing failed')
          end
        end
      end
    end
  end

  context 'custom error messages' do
    subject do
      described_class.new(app) do |config|
        config.public_rsa_sha256_key_from_keyid { |key_id| File.read('spec/support/fixtures/rsa256/public.pem') if key_id == 'Test' }
        config.bad_request do |message|
          [400,
           {'Content-Type' => 'text/plain',
            'Content-Length' => "#{message.size}",
           },
           ['custom bad request error']
          ]
        end
        config.unauthorized do |message|
          [401,
           {'Content-Type' => 'text/plain',
            'Content-Length' => "#{message.size}",
           },
           ['custom unauthorized error']
          ]
        end
      end
    end

    let(:request) { Rack::MockRequest.new(subject) }
    let(:request_path) { 'http://example.com/foo?param=value&pet=dog' }
    let(:http_headers) { {
        input: '{"hello": "world"}',
        'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT',
        'HTTP_CONTENT_TYPE' => 'application/json',
        'HTTP_DIGEST' => 'SHA-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=',
    } }


    it 'returns custom bad request error' do
      response = request.post(request_path, http_headers)
      expect(response.status).to eq(400)
      expect(response.body).to eq('custom bad request error')
    end

    it 'returns custom unauthorized error' do
      response = request.post(request_path, http_headers.merge('HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="rsa-sha256",signature="asdfasdfa"'))
      expect(response.status).to eq(401)
      expect(response.body).to eq('custom unauthorized error')
    end
  end
end
