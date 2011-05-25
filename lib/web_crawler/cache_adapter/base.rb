class WebCrawler::CacheAdapter::Base

  def expired?(response, &block)
    block_result = block_given? ? block.call : false
    (response.foul? && response.date < expire_within) || block_result
  end

  def expire_within(seconds = nil)
    Time.now - (seconds || WebCrawler.config.cache.expire_within)
  end

  def put response
    raise NotImplementedError
  end

  def set response
    put response
  end

  def get uri
    raise NotImplementedError
  end

  def exist? uri
    raise NotImplementedError
  end

end