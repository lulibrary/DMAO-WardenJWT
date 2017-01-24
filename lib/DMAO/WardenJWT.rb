require "DMAO/WardenJWT/version"

require 'DMAO/WardenJWT/strategy'

Warden::Strategies.add(:dmao_jwt, DMAO::WardenJWT::Strategy)