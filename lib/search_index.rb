class SearchIndex
  attr_reader :name

  def initialize(name, rummager_url, options = {})
    @name = name
    @rummager_url = rummager_url.sub(%r{/$}, "")
    @logger = options[:logger]
    @kernel = options[:kernel] || Kernel
    @retries = options[:retries] || 3
  end

  def add(entry)
    (1..@retries).each do |i|
      begin
        RestClient.post(rummager_endpoint, MultiJson.encode([entry]), content_type: :json, accept: :json)
        return true
      rescue RestClient::RequestFailed
        raise if i == @retries
        @kernel.sleep(5)
      end
    end
  end

  def add_batch(entries)
  end

  def delete(link)
  end

  def commit
  end

private
  def rummager_endpoint
    "#{@rummager_url}/#{@name}/documents"
  end
end