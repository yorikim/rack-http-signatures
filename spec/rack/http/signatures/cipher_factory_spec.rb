require 'spec_helper'

describe Rack::Http::Signatures::CipherFactory do
  it 'returns rsa256' do
    expect(described_class.create('rsa-sha256')).to eq(Rack::Http::Signatures::Ciphers::RSA256)
  end

  it 'raises UnknownAlgorithmError' do
    expect { described_class.create('unknown-algorithm') }.to raise_error(Rack::Http::Signatures::Errors::UnknownAlgorithmError, 'Unknown algorithm')
  end
end
