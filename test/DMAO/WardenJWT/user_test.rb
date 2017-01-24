require 'test_helper'
require 'DMAO/WardenJWT/user'

class DMAO::WardenJWT::UserTest < Minitest::Test

  def setup
    @valid_attributes = {
        uid: 1231241,
        subject_id: 'testing@example.com',
        institution_id: 123,
        roles: [
            'institution_admin'
        ]
    }
    @jwt_claims = {
        "sub" => 'testing@example.com',
        "dmao" => {
            "uid" => 12345,
            "institution_id" => 12345,
            "roles" => [
                "institution_admin"
            ],
        }
    }
    ENV['JWT_CUSTOM_CLAIMS_ATTRIBUTE'] = 'dmao'
  end

  def teardown
    ENV['JWT_CUSTOM_CLAIMS_ATTRIBUTE'] = ''
  end

  def test_sets_attributes_on_entity_when_valid_attributes

    user = ::DMAO::WardenJWT::User.new(@valid_attributes)

    assert_equal @valid_attributes[:uid], user.id
    assert_equal @valid_attributes[:subject_id], user.subject_id
    assert_equal @valid_attributes[:institution_id], user.institution_id
    assert_equal @valid_attributes[:roles], user.roles

  end

  def test_sets_non_specified_attributes_to_nil

    missing_attributes = {
        uid: 1231241
    }

    user = ::DMAO::WardenJWT::User.new(missing_attributes)

    assert_equal missing_attributes[:uid], user.id
    assert_nil user.subject_id
    assert_nil user.institution_id
    refute_nil user.roles
    assert_equal [], user.roles

  end

  def test_from_claims_returns_instance_of_user

    user = ::DMAO::WardenJWT::User.from_jwt_claims @jwt_claims

    assert_instance_of ::DMAO::WardenJWT::User, user

  end

  def test_intialises_with_correct_values_from_claims

    user = ::DMAO::WardenJWT::User.from_jwt_claims @jwt_claims

    assert_equal @jwt_claims["dmao"]["uid"], user.id
    assert_equal @jwt_claims["sub"], user.subject_id
    assert_equal @jwt_claims["dmao"]["institution_id"], user.institution_id
    assert_equal @jwt_claims["dmao"]["roles"], user.roles

  end

  def test_sets_uid_to_subject_if_attribute_not_set

    jwt_claims = {
        "sub" => 'testing@example.com',
        "dmao" => {
            "institution_id" => 12345,
            "roles" => [
                "institution_admin"
            ],
        }
    }

    user = ::DMAO::WardenJWT::User.from_jwt_claims jwt_claims

    assert_equal jwt_claims["sub"], user.id
    assert_equal jwt_claims["sub"], user.subject_id
    assert_equal jwt_claims["dmao"]["institution_id"], user.institution_id
    assert_equal jwt_claims["dmao"]["roles"], user.roles

  end

  def test_returns_true_if_user_has_role_by_string_symbol

    user = ::DMAO::WardenJWT::User.new(@valid_attributes)

    assert user.has_role? "institution_admin"
    assert user.has_role? :institution_admin

  end

  def test_returns_true_if_user_doesnot_have_role_by_string_symbol

    user = ::DMAO::WardenJWT::User.new(@valid_attributes)

    refute user.has_role? "admin"
    refute user.has_role? :admin

  end

end