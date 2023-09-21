require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should  accept single format" do
    p = Post.new(input: "8 IMG")
    output = p.generate_bundles
    expected_output = {"IMG": "8 IMG $450: 1 x 5 $450 "}.as_json
    assert_equal output, expected_output
  end

  test "should  accept multiple formats" do
    p = Post.new input: "10 IMG 15 FLAC 13 VID"
    output = p.generate_bundles
    expected_output = {"IMG"=>"10 IMG $800: 1 x 10 $800 ", "FLAC"=>"15 FLAC $1957.5: 1 x 9 $1147.5 1 x 6 $810 ", "VID"=>"13 VID $2370: 2 x 5 $900 1 x 3 $570 "}.as_json
    assert_equal output, expected_output
  end

  test "should not accept invalid format" do
    p = Post.new(input: "8 images")
    output = p.generate_bundles
    expected_output = {}.as_json
    assert_equal output, expected_output
  end

  test "should contain minimal number of bundles" do
    bundles = Post.new(input: "9 flac").generate_bundles
    expected_output = {"FLAC"=>"9 FLAC $1147.5: 1 x 9 $1147.5 "}.as_json
    assert_equal bundles, expected_output

    bundles = Post.new(input: "21 flac").generate_bundles
    expected_output = {"FLAC"=>"21 FLAC $2722.5: 2 x 9 $1147.5 1 x 3 $427.5 "}.as_json
    assert_equal bundles, expected_output
  end

  test "should filter out invalid format" do
    bundles = Post.new(input: "8 images 21 flac").generate_bundles
    expected_output = {"FLAC"=>"21 FLAC $2722.5: 2 x 9 $1147.5 1 x 3 $427.5 "}.as_json
    assert_equal bundles, expected_output
  end

end
