module DMAO
  module WardenJWT
    class User

      attr_reader(:id, :subject_id, :institution_id, :roles)

      def initialize(attributes)

        @id = attributes[:uid] || nil
        @subject_id = attributes[:subject_id] || nil
        @institution_id = attributes[:institution_id] || nil
        @roles = attributes[:roles] || []

      end

      def self.from_jwt_claims jwt_claims

        custom_claims = ENV['JWT_CUSTOM_CLAIMS_ATTRIBUTE']

        uid = jwt_claims[custom_claims]["uid"].nil? ? jwt_claims["sub"] : jwt_claims[custom_claims]["uid"]

        attributes = {
            uid: uid,
            subject_id: jwt_claims["sub"],
            institution_id: jwt_claims[custom_claims]["institution_id"],
            roles: jwt_claims[custom_claims]["roles"]
        }

        new(attributes)

      end

      def has_role? role

        @roles.include? role.to_s

      end

    end
  end
end