require 'spec_helper'

describe Rack::Http::Signatures::CipherFactory do
  {'rsa-sha256' => Rack::Http::Signatures::Ciphers::RSA256,
   'hmac-sha256' => Rack::Http::Signatures::Ciphers::HS256,
  }.each do |algorithm, klass|
    it "returns #{algorithm}" do
      expect(described_class.create(algorithm)).to eq(klass)
    end
  end

  it 'raises UnknownAlgorithmError' do
    expect { described_class.create('unknown-algorithm') }.to raise_error(described_class::UnknownAlgorithmError, 'Unknown algorithm')
  end
end
