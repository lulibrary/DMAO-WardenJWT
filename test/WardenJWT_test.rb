require 'test_helper'

class DMAO::WardenJWTTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DMAO::WardenJWT::VERSION
  end
end
