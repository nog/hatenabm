require 'test/unit'
require 'hatenabm'

class TestHatenaBM < Test::Unit::TestCase

  def setup
    @hatenabm = HatenaBM.new(:user => "username", :pass => "password")
  end

  def test_recent
    #assert_match(
    #  /^<\?xml version=\"1\.0\" encoding=\"utf\-8\"\?>/,
    #  @hatenabm.recent
    #)
  end
  
  def test_post
    #assert_equal(
    #  true,
    #  @hatenabm.post(
    #    :title => "bookmark's title", 
    #    :link => "http://www.example.com",
    #    :tags => "foo bar",
    #    :summary => "this is example post."
    #  )
    #)
  end

  def test_get 
    #assert_match(
    #  /^<\?xml version=\"1\.0\" encoding=\"utf\-8\"\?>/,
    #  @hatenabm.get(:eid => "4211817")
    #)
  end

  def test_modify
    #assert(
    #  true,
    #  @hatenabm.modify(
    #    :eid => "421817", 
    #    :tags => "bar com",
    #    :summary => "modify bookmark's description"
    #  )
    #)
  end

  def test_delete
    #assert(
    #  true,
    #  @hatenabm.delete(:eid => "421817")
    #)
  end
  
  def test_invalid_access
    #assert_raises(RuntimeError) do
    #  @hatenabm.post(:title => "invalid", :summary => "summary")
    #end

    #assert_raises(RuntimeError) do
    #  @hatenabm.get(:invalide => "421817")
    #end

    #assert_raises(RuntimeError) do
    #  @hatenabm.modify(:summary => "summary")
    #end

    #assert_raises(RuntimeError) do
    #  @hatenabm.delete(:invalid => "421817")
    #end

    #assert_raises(RuntimeError) do
    #  @hatenabm.delete(:eid => "invalid")
    #end
  end
end
