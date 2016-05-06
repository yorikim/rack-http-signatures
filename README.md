[![Travis](https://api.travis-ci.org/CurrencyCloud/rack-http-signatures.svg)](https://travis-ci.org/CurrencyCloud/rack-http-signatures)

# rack-http-signatures
Middleware implementing draft 5 of the Signing HTTP Messages specification

## Installation

You don't need this source code unless you want to modify the gem. If you just want to use the library in your application, you should run:

```bash
gem install rack-http-signatures
```

Or add gem to your Gemfile:

```ruby
gem 'rack-http-signatures'
```

If you want to build the gem from source:

```bash
gem build rack-http-signatures.gemspec
```

### Rails
Add middleware to your application.rb:
```ruby
config.middleware.use Rack::Http::Signatures::VerifySignature do |config|
  config.public_rsa_sha256_key_from_keyid { |key_id| User.find_by(email: key_id).public_rsa256_key }
  config.public_hmac_sha256_key_from_keyid { |key_id| User.find_by(email: key_id).hs256_key }
end
```

Sample project: https://github.com/yorikim/rails_rack_http_signatures

### Sinatra
Add middleware to your application class:
```ruby
require 'sinatra'
require 'rack/http/signatures'

class SampleHttpSignaturesApp < Sinatra::Base
  use Rack::Http::Signatures::VerifySignature do |config|
    config.public_rsa_sha256_key_from_keyid { |key_id| File.read('fixtures/rsa256/public.pem') if key_id == 'Test' }
    config.public_hmac_sha256_key_from_keyid { |key_id| File.read('fixtures/hs256/key.txt') if key_id == 'Test' }
  end

  get '/' do
    "Hello, world!"
  end
end
```

Sample project: https://github.com/yorikim/sinatra_rack_http_signatures


### Rack
Add middleware to your config.ru file:
```ruby
require 'rack/http/signatures'

use Rack::Http::Signatures::VerifySignature do |config|
  config.public_rsa_sha256_key_from_keyid do |key_id|
    File.read('spec/support/fixtures/rsa256/public.pem') if key_id == 'Test'
  end
  config.public_hmac_sha256_key_from_keyid do |key_id|
    File.read('spec/support/fixtures/hs256/key.txt') if key_id == 'Test'
  end
end

run lambda { |env|
  [200,
   {'Content-Type' => 'text/plain'},
   ['Hello, World!']
  ]
}
```

## Sending Authenticated Requests
Use OpenSSL library for creating signature.

### RSA SHA256
```
openssl sha -sha256 -sign private.pem < data.txt | base64
```

### HMAC SHA256
```
echo -n 'date: Thu, 05 Jan 2014 21:31:40 GMT' | openssl sha256 -hmac 'some secret key' | sed 's/^.* //' | tr -d '\n' | base64
```


## Config
Define follow methods in config:
```
public_rsa_sha256_key_from_keyid
public_hmac_sha256_key_from_keyid
```


## Supported algorithms
* RSA SHA256
* HMAC SHA256

Note: ecdsa-sha256 **IS NOT** supported.

## Supported Ruby versions

This library aims to support and is [tested against][travis] the following Ruby
implementations:

* MRI 1.9.3
* MRI 2.0.0
* MRI 2.1.0
* MRI 2.2.0
* [JRuby][jruby]
* [Rubinius][rubinius]

[travis]:    https://travis-ci.org/CurrencyCloud/rack-http-signatures
[jruby]:     http://jruby.org/
[rubinius]:  http://rubini.us/
[license]:   LICENSE.md
