# encoding: utf-8
# tests/routes/home_spec.rb

require File.expand_path '../../helper.rb', __FILE__

describe "Home Page Statics" do
  before do
    Mongoid.purge!
  end

  it "Show root" do
    get "/"
    assert_equal 200, last_response.status
    last_response.body.must_include "Oszu"
  end

end
