require 'fast_test_helper'

class SearchIndexTest < ActiveSupport::TestCase
  def sample_document
    {link: "/a_document"}
  end

  def sample_documents(n)
    (1..n).map do |i|
      {link: "/a_document_#{i}"}
    end
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

  test "when we add a batch of documents, they are batch posted to rummager" do
    stub_request(:post, "http://rummager.test/government/documents").
      to_return(status: 200, body: '{"status":"OK"}')

    index = SearchIndex.new("government", "http://rummager.test/")
    index.add_batch(sample_documents(2))

    assert_requested :post, "http://rummager.test/government/documents" do |request|
      request.body == MultiJson.encode(sample_documents(2))
    end
  end

  test "when we add a large number of batch of documents, they are split into smaller batches" do
    stub_request(:post, "http://rummager.test/government/documents").
      to_return(status: 200, body: '{"status":"OK"}')

    sample = sample_documents(3)
    index = SearchIndex.new("government", "http://rummager.test/", batch_size: 2)
    index.add_batch(sample)

    assert_requested :post, "http://rummager.test/government/documents", times: 1 do |request|
      request.body == MultiJson.encode(sample[0..1])
    end
    assert_requested :post, "http://rummager.test/government/documents", times: 1 do |request|
      request.body == MultiJson.encode(sample[2..2])
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
