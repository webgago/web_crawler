module FakeWebGenerator

  def self.included(base)
    generate_web(['http://otherhost.ru/1',
                  'http://otherhost.ru/2',
                  'http://otherhost.ru/3',
                  'http://example.com/1',
                  'http://example.com/2',
                  'http://example.com/3',
                  'http://example.com/2323.html',
                  'http://example.com/2323.html?rr=1',
                  'http://example.com/follower?rr=1'])

    FakeWeb.register_uri(:get, urls_board_path, :body => follower_body)
  end

  def generate_web(urls)
    @@known_web_urls ||= []
    @@known_web_urls << urls
    @@known_web_urls.flatten!
    @@known_web_urls.uniq!

    urls.each do |url|
      FakeWeb.register_uri(:get, url, :body => "Example body for url #{url}")
    end
  end
  module_function :generate_web

  def follower_body
    "Example body for http://example.com/follower" <<
    @@known_web_urls.map { |u| "<a href='#{u}'>link text</a>" }.join("\n")
  end
  module_function :follower_body

  def urls_board_path
    'http://example.com/follower'
  end
  module_function :urls_board_path

  def known_urls
    @@known_web_urls
  end

end