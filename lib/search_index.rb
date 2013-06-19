require 'benchmark'

class SearchIndex
  attr_reader :name

  def initialize(rummager_url, name, options = {})
    @name = name
    @rummager_url = rummager_url.sub(%r{/$}, "")
    @logger = options[:logger] || NullLogger.instance
    @kernel = options[:kernel] || Kernel
    @retries = options[:retries] || 3
    @batch_size = options[:batch_size] || 100
  end

  def add(entry)
    repeatedly do
      post_batch [entry]
    end
  end

  def add_batch(entries)
    entries.each_slice(@batch_size) do |batch|
      repeatedly do
        post_batch(batch)
      end
    end
  end

  def delete(link)
  end

  def commit
  end

private
  def post_batch(batch)
    response = nil
    @logger.info "Posting #{batch.size} document(s) to #{rummager_endpoint}"
    @logger.debug batch.map {|entry| entry['link']}.join(", ")
    call_time = Benchmark.realtime do
      response = RestClient.post(rummager_endpoint, MultiJson.encode(batch), content_type: :json, accept: :json)
    end
    @logger.debug "Response: #{response} took (#{call_time})"
    response
  end

  def rummager_endpoint
    "#{@rummager_url}/#{@name}/documents"
  end

  def repeatedly(&block)
    (1..@retries).each do |i|
      begin
        return yield
      rescue RestClient::RequestFailed => e
        @logger.warn e
        raise if i == @retries
        @logger.info "Retrying... attempt #{i}"
        @kernel.sleep(5 * i)
      end
    end
  end
end