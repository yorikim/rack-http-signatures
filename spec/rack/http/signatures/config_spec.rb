describe Rack::Http::Signatures::Config do
  it 'defines signleton method get_key_from_keyid in KeyManager' do
    block_is = double('block')
    block = -> {
      block_is.run
    }

    expect(Rack::Http::Signatures::KeyManager).to receive(:send).with(:define_singleton_method, :public_rsa_sha256_key_from_keyid).and_yield
    expect(block_is).to receive(:run)

    subject.public_rsa_sha256_key_from_keyid &block
  end

  it 'not defines signleton method for Unknown algorithm' do
    block_is = double('block')
    block = -> {
      block_is.run
    }

    expect { subject.public_unknown_algorithm_key_from_keyid &block }.to raise_error NoMethodError
  end
end
