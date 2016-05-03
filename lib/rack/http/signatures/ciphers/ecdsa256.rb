require 'openssl'

if RUBY_PLATFORM == 'java'
  import 'java.math.BigInteger'
  import 'java.security.SecureRandom'
  import 'java.io.ByteArrayOutputStream'
  import 'org.bouncycastle.asn1.sec.SECNamedCurves'
  import 'org.bouncycastle.asn1.x9.X9ECParameters'
  import 'org.bouncycastle.asn1.ASN1InputStream'
  import 'org.bouncycastle.asn1.DERInteger'
  import 'org.bouncycastle.asn1.DERSequenceGenerator'
  import 'org.bouncycastle.asn1.DLSequence'
  import 'org.bouncycastle.crypto.signers.ECDSASigner'
  import 'org.bouncycastle.crypto.params.ECDomainParameters'
  import 'org.bouncycastle.crypto.params.ECPrivateKeyParameters'
  import 'org.bouncycastle.crypto.params.ECPublicKeyParameters'
  import 'org.bouncycastle.math.ec.ECPoint'

  module ::OpenSSL::PKey
    class EC
      attr_accessor :private_key, :public_key
      attr_reader :group

      def initialize(curve_name)
        params = SECNamedCurves.getByName(curve_name)
        @curve = ECDomainParameters.new(params.getCurve(), params.getG(), params.getN(), params.getH())
        @group = ::OpenSSL::PKey::EC::Group.new
      rescue
        raise OpenSSL::PKey::ECError.new($!.message)
      end

      def generate_key
        @private_key = random_bn

        @group = ::OpenSSL::PKey::EC::Group.new

        point = @curve.getG().multiply(BigInteger.new(get_java_bytes(@private_key)))
        point = compressPoint(point) if @group.point_conversion_form == :compressed
        public_key_java_bytes = point.getEncoded()
        public_key_bn = get_bn_from_java_bytes(public_key_java_bytes)
        @public_key = ::OpenSSL::PKey::EC::Point.new(self.group, public_key_bn)

        self
      rescue
        raise OpenSSL::PKey::ECError.new($!.message)
      end

      def dsa_sign_asn1(data)
        private_key_big_integer = BigInteger.new(get_java_bytes(@private_key))

        signer = ECDSASigner.new
        signer.init(true, ECPrivateKeyParameters.new(private_key_big_integer, @curve))
        components = signer.generateSignature(data.bytes.to_a)
        signature = get_der_java_bytes(components[0], components[1])
        signatureBytes = signature.collect(&:to_i).pack('c*')
      rescue
        raise OpenSSL::PKey::ECError.new($!.message)
      end

      def dsa_verify_asn1(data, signature)
        d = data.unpack('c*').to_java(:byte)
        r, s = get_r_and_s_from_bytes(signature.unpack('c*').to_java(:byte))
        pub = get_java_bytes(public_key.to_bn)

        signer = ECDSASigner.new
        params = ECPublicKeyParameters.new(@curve.getCurve().decodePoint(pub), @curve)
        signer.init(false, params)
        signer.verifySignature(d, r, s)
      rescue
        raise OpenSSL::PKey::ECError.new($!.message)
      end

      private

      def get_r_and_s_from_bytes(der_encoded_java_bytes)
        decoder = ASN1InputStream.new(der_encoded_java_bytes)
        seq = decoder.readObject()
        [seq.getObjectAt(0).getPositiveValue(), seq.getObjectAt(1).getPositiveValue()]
      ensure
        decoder.close
      end

      def get_der_java_bytes(r, s)
        bos = ByteArrayOutputStream.new(72)
        seq = DERSequenceGenerator.new(bos)
        seq.addObject(DERInteger.new(r))
        seq.addObject(DERInteger.new(s))
        seq.close()
        bos.toByteArray()
      end

      def get_java_bytes(number)
        hex_string = number.to_s(16)
        bytes = []
        if hex_string.length % 2 == 1
          bytes << ['0' + hex_string[0]].pack('H*').unpack('c*')[0]
          hex_string = hex_string[1..-1]
        end
        bytes += [hex_string].pack('H*').unpack('c*')

        bytes.to_java(:byte)
      end

      def get_bn_from_java_bytes(java_bytes)
        ruby_hex_s = java_bytes.collect(&:to_i).pack('c*').unpack('H*').first
        ::OpenSSL::BN.new(ruby_hex_s, 16)
      end

      def random_bn
        OpenSSL::BN.new(OpenSSL::Random.random_bytes(32).unpack('H*').first, 16)
      end
    end

    class ECError < OpenSSL::PKey::PKeyError
    end

    class EC::Point
      attr_accessor :group

      def initialize(group, bn)
        self.group = group
        @bn = bn
      end

      def to_bn
        @bn
      end
    end

    class EC::Group
      attr_accessor :point_conversion_form

      def initialize
        self.point_conversion_form = :uncompressed
      end

      def point_conversion_form=(form)
        raise ArgumentError.new("only :compressed and :uncompressed form supported: #{form}") unless [:uncompressed, :compressed].include?(form)

        @point_conversion_form = form
      end
    end
  end
end

module Rack::Http::Signatures::Ciphers
  module ECDSA256
    class << self
      DIGEST = OpenSSL::Digest::SHA256.new

      def verify(key, signature, data)
        public_key = OpenSSL::PKey::EC.new(key)
        public_key.verify(DIGEST, signature, data)
      rescue OpenSSL::PKey::PKeyError
        false
      end
    end
  end
end
