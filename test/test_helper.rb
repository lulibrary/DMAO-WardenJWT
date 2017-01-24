$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start

require 'DMAO/WardenJWT'

require 'minitest/autorun'
require 'mocha/mini_test'