require 'spec_helper'
require 'base64'

describe Rack::Http::Signatures::Verifier do
  let(:algorithm) { 'rsa-sha256' }
  let(:public_key) { 'some key' }
  let(:signature) { 'some signature in base64' }
  let(:data) { 'some data' }

  it 'calls Cipher Factory' do
    expect(Rack::Http::Signatures::Ciphers::RSA256).to receive(:verify).with(public_key, Base64.decode64(signature), data)
    described_class.verify(algorithm, public_key, signature, data)
  end
end
