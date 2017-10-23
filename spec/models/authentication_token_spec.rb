require 'rails_helper'

RSpec.describe AuthenticationToken do
  before do
    @aud = AuthenticationToken.token_audience_identifier.call
    @iss = AuthenticationToken.token_issuer_identifier.call
    @key = AuthenticationToken.token_secret_signature_key.call
  end

  it 'verifies the audience when token_audience is present' do
    verify_options = { verify_iss: false }
    AuthenticationToken.any_instance.stubs(:token_audience_identifier).returns(-> { 'foo' })
    token = JWT.encode({ sub: '1' }, @key, 'HS256')

    expect { AuthenticationToken.new(token: token, verify_options: verify_options) }
      .to raise_error(JWT::InvalidAudError)
  end

  it 'verifies the issuer when token_issuer is present' do
    verify_options = { verify_aud: false }
    AuthenticationToken.any_instance.stubs(:token_issuer_identifier).returns(-> { 'bar' })
    token = JWT.encode({ sub: '1' }, @key, 'HS256')

    expect { AuthenticationToken.new(token: token, verify_options: verify_options) }
      .to raise_error(JWT::InvalidIssuerError)
  end

  it 'validates the expiration claim by default' do
    token = AuthenticationToken.new(payload: { sub: 'foo' }).token

    Timecop.travel(25.hours.from_now) do
      expect { AuthenticationToken.new(token: token) }
        .to raise_error(JWT::ExpiredSignature)
    end
  end

  it 'does not validate expiration claim with a nil token_expiry_time' do
    AuthenticationToken.any_instance.stubs(:token_expiry_time).returns(nil)
    token = AuthenticationToken.new(payload: { sub: 'foo' }).token

    Timecop.travel(10.years.from_now) do
      expect(AuthenticationToken.new(token: token).payload)
        .to_not have_key('exp')
    end
  end

  it 'validates aud when verify_options[:verify_aud] is true' do
    verify_options = { verify_aud: true }
    token = JWT.encode({ sub: '1', iss: @iss }, @key, 'HS256')

    expect { AuthenticationToken.new(token: token, verify_options: verify_options) }
      .to raise_error(JWT::InvalidAudError)
  end

  it 'does not validate aud when verify_options[:verify_aud] is false' do
    verify_options = { verify_aud: false, verify_iss: false }
    token = JWT.encode({ sub: '1' }, @key, 'HS256')

    expect(AuthenticationToken.new(token: token, verify_options: verify_options).payload)
      .to_not have_key('aud')
  end

  it 'validates iss when verify_options[:verify_iss] is true' do
    verify_options = { verify_iss: true, iss: 'bar' }
    AuthenticationToken.any_instance.stubs(:token_audience_identifier).returns(-> { 'bar' })
    token = JWT.encode({ sub: '1' }, @key, 'HS256')

    expect { AuthenticationToken.new(token: token, verify_options: verify_options) }
      .to raise_error(JWT::InvalidIssuerError)
  end

  it 'validates the expiration claim by default' do
    AuthenticationToken.any_instance.stubs(:token_issuer_identifier).returns(-> { 'foo' })
    token = JWT.encode({ sub: '1', iss: 'bar' }, @key, 'HS256')

    expect { AuthenticationToken.new(token: token) }
      .to raise_error(JWT::InvalidIssuerError)
  end

  it 'does not validate iss when verify_options[:verify_iss] is false' do
    verify_options = { verify_aud: false, verify_iss: false }
    token = JWT.encode({ sub: '1' }, @key, 'HS256')

    expect(AuthenticationToken.new(token: token, verify_options: verify_options).payload)
      .to_not have_key('iss')
  end

  it 'validates expiration when verify_options[:verify_expiration] is true' do
    verify_options = { verify_expiration: true }
    token = AuthenticationToken.new(payload: { sub: 'foo' }).token

    Timecop.travel(25.hours.from_now) do
      expect { AuthenticationToken.new(token: token, verify_options: verify_options) }
        .to raise_error(JWT::ExpiredSignature)
    end
  end

  it 'does not validate expiration when verify_options[:verify_expiration] is false' do
    verify_options = { verify_expiration: false }
    token = AuthenticationToken.new(payload: { sub: 'foo' }).token

    Timecop.travel(25.hours.from_now) do
      expect(AuthenticationToken.new(token: token, verify_options: verify_options).payload)
        .to have_key('exp')
    end
  end

  it 'AuthenticationToken has all payloads' do
    payload = AuthenticationToken.new(payload: { sub: 'foo' }).payload

    expect(payload).to have_key(:sub)
    expect(payload).to have_key(:exp)
  end

  it 'is serializable' do
    token = JWT.encode({ sub: '1', aud: @aud, iss: @iss }, @key, 'HS256')
    access_token = AuthenticationToken.new(token: token)

    expect(access_token.to_json).to eq("{\"token\":\"#{token}\"}")
  end
end
