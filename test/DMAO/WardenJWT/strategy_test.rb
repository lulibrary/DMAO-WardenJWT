require 'test_helper'
require 'securerandom'
require 'DMAO/WardenJWT/user'
require 'DMAO/WardenJWT/strategy'

class DMAO::WardenJWT::StrategyTest < MiniTest::Test

  def setup

    ENV['JWT_VERIFY_IAT'] = 'false'
    ENV['JWT_VERIFY_AUD'] = 'true'
    ENV['JWT_VERIFY_ISS'] = 'true'
    ENV['JWT_SECRET'] = 'abcd-1234-abcd-1234'
    ENV['JWT_ISSUER'] = 'dmao-jwt-dev'
    ENV['JWT_AUDIENCE'] = 'dmao'
    ENV['JWT_CUSTOM_CLAIMS_ATTRIBUTE'] = 'dmao'

    @request = mock
    @strategy = ::DMAO::WardenJWT::Strategy.new(nil)

    current_time = Time.now.to_i

    @payload = {
        "iss" => ENV['JWT_ISSUER'],
        "sub" => "testing@exmaple.com",
        "iat" => current_time,
        "exp" => current_time + 3600,
        "aud" => ENV['JWT_AUDIENCE'],
        "jti" => SecureRandom.uuid.tr('-', ''),
        "dmao" => {
            "institution_id" => nil,
            "roles" => [
                "dmao_admin"
            ]
        }
    }

    @valid_jwt = JWT.encode @payload, ENV['JWT_SECRET'], 'HS256'
    @request.stubs(:get_header).returns("Bearer #{@valid_jwt}")
    @strategy.stubs(:request).returns(@request)

  end

  def teardown
    ENV['JWT_VERIFY_IAT'] = ''
    ENV['JWT_VERIFY_AUD'] = ''
    ENV['JWT_VERIFY_ISS'] = ''
    ENV['JWT_SECRET'] = ''
    ENV['JWT_ISSUER'] = ''
    ENV['JWT_AUDIENCE'] = ''
    ENV['JWT_CUSTOM_CLAIMS_ATTRIBUTE'] = ''
  end

  def  test_strategy_is_valid_when_jwt_specified_in_get_params

    @strategy.stubs(:params).returns({jwt: @valid_jwt})

    assert @strategy.valid?

  end

  def test_strategy_is_valid_when_jwt_is_specified_in_header

    @strategy.stubs(:params).returns({})

    assert @strategy.valid?

  end

  def test_strategy_is_not_valid_when_jwt_specified_in_header_is_not_prefixed_by_bearer

    @request.stubs(:get_header).returns(@valid_jwt)
    @strategy.stubs(:request).returns(@request)
    @strategy.stubs(:params).returns({})

    refute @strategy.valid?

  end

  def test_strategy_is_not_stored
    refute @strategy.store?
  end

  def test_jwt_returns_nil_if_jwt_is_not_specified

    @request.stubs(:get_header).returns('')
    @strategy.stubs(:request).returns(@request)
    @strategy.stubs(:params).returns({})

    assert_nil @strategy.jwt

  end

  def test_fail_is_called_when_jwt_is_not_valid

    @strategy.stubs(:params).returns({})

    @strategy.expects(:valid_jwt?).once.returns(false)

    @strategy.expects(:fail!).with(:invalid_jwt)

    @strategy.authenticate!

  end

  def test_success_is_called_creating_new_jwt_user_when_jwt_is_valid

    @strategy.stubs(:params).returns({})

    @strategy.expects(:valid_jwt?).once.returns(true)

    DMAO::WardenJWT::User.expects(:from_jwt_claims).once.returns(DMAO::WardenJWT::User.new({}))

    @strategy.expects(:success!)

    @strategy.authenticate!

  end

  def test_logs_error_and_returns_nil_when_jwt_signature_expired

    @strategy.stubs(:params).returns({})

    JWT.expects(:decode).raises(JWT::ExpiredSignature)
    ::Logger.any_instance.expects(:info).with('JWT - Expired Signature').once

    assert_nil @strategy.decode_jwt

  end

  def test_logs_error_and_returns_nil_when_jwt_invalid_signature

    @strategy.stubs(:params).returns({})

    JWT.expects(:decode).raises(JWT::InvalidIssuerError)
    ::Logger.any_instance.expects(:info).with('JWT - Invalid Issuer').once

    assert_nil @strategy.decode_jwt

  end

  def test_logs_error_and_returns_nil_when_invalid_audience

    @strategy.stubs(:params).returns({})

    JWT.expects(:decode).raises(JWT::InvalidAudError)
    ::Logger.any_instance.expects(:info).with('JWT - Invalid Audience').once

    assert_nil @strategy.decode_jwt

  end

  def test_logs_error_and_returns_nil_when_invalid_issued_at_time

    @strategy.stubs(:params).returns({})

    JWT.expects(:decode).raises(JWT::InvalidIatError)
    ::Logger.any_instance.expects(:info).with('JWT - Invalid Issued At Timestamp').once

    assert_nil @strategy.decode_jwt

  end

  def test_logs_error_and_returns_nil_when_jwt_verification_fails

    @strategy.stubs(:params).returns({})

    JWT.expects(:decode).raises(JWT::VerificationError)
    ::Logger.any_instance.expects(:info).with('JWT - Signature Verification Failed').once

    assert_nil @strategy.decode_jwt

  end

  def test_logs_error_and_returns_nil_when_error_decoding_jwt

    @strategy.stubs(:params).returns({})

    JWT.expects(:decode).raises(JWT::DecodeError)
    ::Logger.any_instance.expects(:info).with('JWT - Error decoding JWT').once

    assert_nil @strategy.decode_jwt

  end

  def test_jwt_is_not_valid_when_decode_jwt_errors

    @strategy.stubs(:params).returns({})

    @strategy.expects(:decode_jwt).at_least_once.returns(nil)

    refute @strategy.valid_jwt?

  end

  def test_jwt_is_valid_when_decode_jwt_is_successful

    @strategy.stubs(:params).returns({})

    @strategy.expects(:decode_jwt).at_least_once.returns([{}, {sub: "abcde"}])

    assert @strategy.valid_jwt?

  end

  def test_returns_decoded_jwt_when_decode_is_successful

    @strategy.stubs(:params).returns({})

    decoded_jwt = @strategy.decode_jwt

    jwt_header = {"typ"=>"JWT", "alg"=>"HS256"}

    assert_equal [@payload, jwt_header], decoded_jwt

  end

end