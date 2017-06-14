require 'DMAO/WardenJWT/user'
require 'warden'
require 'jwt'
require 'logger'

module DMAO
  module WardenJWT
    class Strategy < ::Warden::Strategies::Base

      def valid?
        !jwt.nil? && !jwt.empty?
      end

      def authenticate!

        valid_jwt? ? success!(User.from_jwt_claims(jwt_claims)) : fail!(:invalid_jwt)

      end

      def store?
        false
      end

      def bearer_token
        pattern = /^Bearer /
        header  = request.env['HTTP_AUTHORIZATION'] # <= env
        header.gsub(pattern, '') if header && header.match(pattern)
      end

      def jwt

        if params["jwt"]
          return  params["jwt"]
        end

        if !bearer_token.nil? && !bearer_token.empty?
          return bearer_token
        end

        nil

      end

      def jwt_claims

        jwt = decode_jwt

        if jwt.nil?
          nil
        else
          jwt[0]
        end

      end

      def decode_jwt

        logger = ::Logger.new(STDOUT)

        verify_iat = ENV['JWT_VERIFY_IAT']
        verify_aud = ENV['JWT_VERIFY_AUD']
        verify_iss = ENV['JWT_VERIFY_ISS']
        jwt_secret = ENV['JWT_SECRET']
        jwt_issuer = ENV['JWT_ISSUER']
        jwt_audience = ENV['JWT_AUDIENCE']

        begin
          decoded_token = JWT.decode jwt, jwt_secret, true, { :verify_iat => verify_iat, :iss => jwt_issuer, :verify_iss => verify_iss, :aud => jwt_audience, :verify_aud => verify_aud, :algorithm => 'HS256'}
        rescue ::JWT::ExpiredSignature
          logger.info('JWT - Expired Signature')
          return nil
        rescue ::JWT::InvalidIssuerError
          logger.info('JWT - Invalid Issuer')
          return nil
        rescue ::JWT::InvalidAudError
          logger.info('JWT - Invalid Audience')
          return nil
        rescue ::JWT::InvalidIatError
          logger.info('JWT - Invalid Issued At Timestamp')
          return nil
        rescue ::JWT::VerificationError
          logger.info('JWT - Signature Verification Failed')
          return nil
        rescue ::JWT::DecodeError
          logger.info('JWT - Error decoding JWT')
          return nil
        end

        decoded_token

      end

      def valid_jwt?

        if decode_jwt.nil?
          return nil
        end

        true

      end

    end
  end
end
