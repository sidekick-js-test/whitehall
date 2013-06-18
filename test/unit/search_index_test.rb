require 'fast_test_helper'

class SearchIndexTest < ActiveSupport::TestCase
  test "can create an index" do
    index = SearchIndex.new("government")
    assert_equal "government", index.name
  end

  test "when we add a single document it is posted to rummager" do
    document = {link: "/foo"}
    json = MultiJson.encode([document])

    stub_request(:post, "http://rummager.test/government/documents").
      to_return(status: 200, body: '{"status":"OK"}')

    index = SearchIndex.new("government", "http://rummager.test/")
    index.add(document)

    assert_requested :post, "http://rummager.test/government/documents" do |request|
      request.body == json &&
        request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

end
