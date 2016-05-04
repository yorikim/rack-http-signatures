require 'spec_helper'
require 'rack/mock'

describe Rack::Http::Signatures::Request do
  let(:valid_signature) { 'jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w=' }
  subject { described_class.new Rack::MockRequest.env_for('http://example.com', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => ('Signature keyId="Test",algorithm="rsa-sha256",headers="date",signature="'+ valid_signature+'"')) }

  it 'returns parsed parameters' do
    expect(subject.parameters).to eq({'keyId' => 'Test', 'algorithm' => 'rsa-sha256', 'headers' => 'date', 'signature' => valid_signature})
  end

  it 'returns nil if paramateres incorrect' do
    subject = described_class.new Rack::MockRequest.env_for('http://example.com', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => ('Signature field="1234",keyId="Test",algorithm="rsa-sha256",headers="date",signature="' + valid_signature + '"'))
    expect(subject.parameters).to eq(nil)
  end

  it 'returns key_id' do
    expect(subject.key_id).to eq('Test')
  end

  it 'returns algorithm' do
    expect(subject.algorithm).to eq('rsa-sha256')
  end

  it 'returns signature' do
    expect(subject.signature).to eq(valid_signature)
  end

  it 'checks authorization type' do
    expect(subject.signature?).to be_truthy
  end

  it 'returns signed data' do
    expect(subject.signed_data).to eq('date: Thu, 05 Jan 2014 21:31:40 GMT')
  end
end
