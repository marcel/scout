require File.dirname(__FILE__) + '/test_helper'

class ResourceTest < ScoutTest
  def test_resource
    resources = {
      r('league', 123)                     => "league/123",
      r('league', 123) + 'players'         => "league/123/players",
      r('league', 123) + 'foo'             => "league/123;foo",
      r('league', 123) + 'bar=baz'         => "league/123;bar=baz",
      r('league', 123) + 'foo' + 'bar=baz' => "league/123;bar=baz;foo",

      r('league', 123) + 'foo' + 'bar=baz' + 'players'          => "league/123;bar=baz;foo/players",
      r('league', 123) + 'foo' + 'bar=baz' + 'players' + 'quux' => "league/123;bar=baz;foo/players;quux",
      r('league', 123) + r('player', 456)                       => "league/123/player/456"
    }

    resources.each do |resource, expected_uri|
      assert_uri resource, expected_uri
    end

    resource = r('league', 123) + 'foo' + 'bar=baz' + 'players' + 'quux' + 'start=0'
    assert_equal resource.league, resource
    assert_equal resource.players, r('players') + 'quux' + 'start=0'
    assert_equal resource.key, 123
    assert resource.foo?
    assert resource.bar?
    assert !resource.no_such_parameter?
    assert_equal resource.bar, "baz"
    assert_equal resource.start, '0'

    resource.start = 100
    assert_equal resource.start, '100'
    resource.bar = 'quux'
    assert_equal resource.bar, 'quux'
  end

  private
    def r(*args)
      Resource.new(*args)
    end

    def assert_uri(resource, expected_uri)
      assert_equal resource.uri, expected_uri
    end
end