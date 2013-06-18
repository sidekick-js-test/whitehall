require 'fast_test_helper'

class SearchIndexTest < ActiveSupport::TestCase
  def sample_document
    {link: "/foo"}
  end

  test "can create an index" do
    index = SearchIndex.new("government", "http://rummager.test/")
    assert_equal "government", index.name
  end

  test "when we add a single document it is posted to rummager" do
    stub_request(:post, "http://rummager.test/government/documents").
      to_return(status: 200, body: '{"status":"OK"}')

    index = SearchIndex.new("government", "http://rummager.test/")
    index.add(sample_document)

    assert_requested :post, "http://rummager.test/government/documents" do |request|
      request.body == MultiJson.encode([sample_document]) &&
        request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  test "returns true on success" do
    stub_request(:post, "http://rummager.test/government/documents").
      to_return(status: 200, body: '{"status":"OK"}')

    index = SearchIndex.new("government", "http://rummager.test/")
    assert index.add(sample_document)
  end

  test "retries on 502 bad gateway error" do
    stub_request(:post, "http://rummager.test/government/documents").
      to_return(status: 502, body: 'Bad gateway').times(1).then.
      to_return(status: 200, body: '{"status":"OK"}')

    kernel = stub("kernel")
    kernel.expects(:sleep).with(5)

    index = SearchIndex.new("government", "http://rummager.test/", kernel: kernel)
    assert index.add({link: "/foo"})
  end

  test "propogates any exception after too many failed attempts" do
    stub_request(:post, "http://rummager.test/government/documents").
      to_return(status: 502, body: 'Bad gateway').times(4)

    kernel = stub("kernel")
    kernel.expects(:sleep).with(5).at_least_once

    index = SearchIndex.new("government", "http://rummager.test/", kernel: kernel)
    assert_raises RestClient::BadGateway do
      index.add({link: "/foo"})
    end
  end
end
