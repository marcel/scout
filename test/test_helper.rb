require 'test/unit'
$:.unshift File.dirname(__FILE__) + '/../lib'
require 'scout'

class ScoutTest < Test::Unit::TestCase
  include Scout
  def default_test; end
end