class SearchIndex
  attr_reader :name

  def initialize(name, rummager_url, options = {})
    @name = name
    @rummager_url = rummager_url.sub(%r{/$}, "")
    @logger = options[:logger]
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
    RestClient.post(rummager_endpoint, MultiJson.encode(batch), content_type: :json, accept: :json)
  end

  def rummager_endpoint
    "#{@rummager_url}/#{@name}/documents"
  end

  def repeatedly(&block)
    (1..@retries).each do |i|
      begin
        return yield
      rescue RestClient::RequestFailed
        raise if i == @retries
        @kernel.sleep(5)
      end
    end
  end
end