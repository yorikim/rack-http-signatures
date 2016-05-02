require 'spec_helper'
require 'rack/mock'

describe Rack::Http::Signatures::Request do
  subject { described_class.new Rack::MockRequest.env_for('http://example.com', 'HTTP_DATE' => 'Thu, 05 Jan 2014 21:31:40 GMT', 'HTTP_AUTHORIZATION' => 'Signature keyId="Test",algorithm="rsa-sha256",headers="date",signature="jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w="') }

  it 'returns parsed parameters' do
    expect(subject.parameters).to eq({'keyId' => 'Test', 'algorithm' => 'rsa-sha256', 'headers' => 'date', 'signature' => 'jKyvPcxB4JbmYY4mByyBY7cZfNl4OW9HpFQlG7N4YcJPteKTu4MWCLyk+gIr0wDgqtLWf9NLpMAMimdfsH7FSWGfbMFSrsVTHNTk0rK3usrfFnti1dxsM4jl0kYJCKTGI/UWkqiaxwNiKqGcdlEDrTcUhhsFsOIo8VhddmZTZ8w='})
  end

  it 'returns key_id' do
    expect(subject.key_id).to eq('Test')
  end

  it 'checks authorization type' do
    expect(subject.signature?).to be_truthy
  end
end
