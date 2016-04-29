require 'spec_helper'

describe Rack::Http::Signatures do
  it 'has a version number' do
    expect(Rack::Http::Signatures::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
