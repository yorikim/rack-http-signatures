require 'spec_helper'
require 'base64'

describe Rack::Http::Signatures::Verifier do
  let(:algorithm) { 'rsa-sha256' }
  let(:key) { 'some key' }
  let(:signature) { 'some signature in base64' }
  let(:data) { 'some data' }

  it 'calls Cipher Factory' do
    expect(Rack::Http::Signatures::Ciphers::RSA256).to receive(:verify).with(key, Base64.decode64(signature), data)
    described_class.verify(algorithm, key, signature, data)
  end
end
