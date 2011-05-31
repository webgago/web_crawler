module RedirectPath

  def redirect_path=(path)
    @redirect_path = path.flatten.compact.map(&:to_s).reject(&:empty?)
  end

  def redirect_path
    @redirect_path
  end

  def redirect?
    !!redirect_path
  end

end

class Net::HTTPResponse
  include RedirectPath
end