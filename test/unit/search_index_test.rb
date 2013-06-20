require 'fast_test_helper'
require 'mocha/setup'
require 'webmock/test_unit'

require 'search_index'

class SearchIndexTest < ActiveSupport::TestCase
  def sample_document
    {link: "/a_document"}
  end

  def sample_documents(n)
    (1..n).map do |i|
      {link: "/a_document_#{i}"}
    end
  end

  def rummager_url
    "http://rummager.test"
  end

  def documents_url
    "#{rummager_url}/government/documents"
  end

  setup do
    @kernel = stub("kernel", sleep: nil)
  end

  test "can create an index" do
    index = SearchIndex.new(rummager_url, "government")
    assert_equal "government", index.name
  end

  test "when we add a single document it is posted to rummager" do
    stub_request(:post, documents_url).
      to_return(status: 200, body: '{"status":"OK"}')

    index = SearchIndex.new(rummager_url, "government")
    index.add(sample_document)

    assert_requested :post, documents_url do |request|
      request.body == MultiJson.encode([sample_document]) &&
        request.headers['Content-Type'] == 'application/json' &&
        request.headers['Accept'] == 'application/json'
    end
  end

  test "when we add a batch of documents, they are batch posted to rummager" do
    stub_request(:post, documents_url).to_return(status: 200, body: '{"status":"OK"}')

    index = SearchIndex.new(rummager_url, "government")
    index.add_batch(sample_documents(2))

    assert_requested :post, documents_url do |request|
      request.body == MultiJson.encode(sample_documents(2))
    end
  end

  test "when we add a large number of batch of documents, they are split into smaller batches" do
    stub_request(:post, documents_url).to_return(status: 200, body: '{"status":"OK"}')

    sample = sample_documents(3)
    index = SearchIndex.new(rummager_url, "government", batch_size: 2)
    index.add_batch(sample)

    assert_requested :post, documents_url, times: 1 do |request|
      request.body == MultiJson.encode(sample[0..1])
    end
    assert_requested :post, documents_url, times: 1 do |request|
      request.body == MultiJson.encode(sample[2..2])
    end
  end

  test "returns true on success" do
    stub_request(:post, documents_url).to_return(status: 200, body: '{"status":"OK"}')

    index = SearchIndex.new(rummager_url, "government")
    assert index.add(sample_document)
  end

  test "sleeps and then retries on 502 bad gateway error" do
    stub_request(:post, documents_url).
      to_return(status: 502, body: 'Bad gateway').times(1).then.
      to_return(status: 200, body: '{"status":"OK"}')

    @kernel.expects(:sleep).with(5)

    index = SearchIndex.new(rummager_url, "government", kernel: @kernel)
    assert index.add(sample_document)
  end

  test "propogates any exception after too many failed attempts" do
    stub_request(:post, documents_url).
      to_return(status: 502, body: 'Bad gateway').times(4)

    index = SearchIndex.new(rummager_url, "government", kernel: @kernel)
    assert_raises RestClient::BadGateway do
      index.add(sample_document)
    end
  end

  test "logs attempts to post to rummager" do
    stub_request(:post, documents_url).to_return(status: 200)
    logger = stub_everything("logger")
    logger.expects(:info).once
    index = SearchIndex.new(rummager_url, "government", logger: logger)
    index.add(sample_document)
  end

  test "logs failed document postings" do
    stub_request(:post, documents_url).
      to_return(status: 502, body: 'Bad gateway').times(1).then.
      to_return(status: 200, body: '{"status":"OK"}')

    logger = stub_everything("logger")
    logger.expects(:warn).once

    index = SearchIndex.new(rummager_url, "government", kernel: @kernel, logger: logger)
    index.add(sample_document)
  end
end
