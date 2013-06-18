class SearchIndex
  attr_reader :name

  def initialize(name, rummager_url, options = {})
    @name = name
    @rummager_url = rummager_url.sub(%r{/$}, "")
    @logger = options[:logger]
  end

  def add(entry)
    RestClient.post(rummager_endpoint, MultiJson.encode([entry]), content_type: :json, accept: :json)
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