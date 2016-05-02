require 'spec_helper'

describe Rack::Http::Signatures::SignatureParametersParser do
  let(:key) { instance_double('HttpSignatures::Key', id: 'pda') }
  let(:algorithm) { instance_double('HttpSignatures::Algorithm::Hmac', name: 'hmac-test') }
  let(:header_list) { instance_double('HttpSignatures::HeaderList', to_str: 'a b c') }
  let(:signature) { instance_double('HttpSignatures::Signature', to_str: 'sigstring') }

  describe '#parse' do
    it 'parse string into hash' do
      header = 'keyId="pda",algorithm="hmac-test",headers="a b c",signature="c2lnc3RyaW5n"'
      hash = {'keyId' => 'pda', 'algorithm' => 'hmac-test', 'headers' => 'a b c', 'signature' => 'c2lnc3RyaW5n'}
      expect(subject.parse(header)).to eq(hash)
    end

    it 'raise error' do
      header = 'keyId="pda",algorithm="hmac-test",headers="a b c",signature="c2lnc3RyaW5n",someField="12345678"'
      expect { subject.parse(header) }.to raise_error(Rack::Http::Signatures::Errors::SignatureParametersParserError, 'unparseable segment: someField="12345678"')
    end
  end
end
