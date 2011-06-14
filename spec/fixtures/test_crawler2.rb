#encoding: utf-8

class TestCrawler2 < WebCrawler::Base

  target "http://www.superjob.ru/export/vacs_to_xml.php"

  log_to "/tmp/file.log" # or Logger.new(...)

  cache_to '/tmp/wcrawler/cache' # or (CacheClass < CacheAdapter).new *args

  context "job", :jobs do

    map 'link', :to => :source_link, :on => :inner_text # default :on => :inner_text
    map 'name', :to => :name
    map 'region', :to => :city_name
    map 'salary', :to => :profit
    map 'description', :to => :description, :filter => :format_description
    map 'contacts', :to => :contact_text
    map 'company', :to => :company, :on => [:attr, :id]
    map 'published', :to => :published_at
    map 'expire', :to => :expire_at
    map 'catalog item', :to => :specialization_ids, :on => nil, :filter => :convert_specs

  end

  protected

  def self.format_description(text)
    @titles ||= ["Условия работы и компенсации:\n",
                 "Место работы:\n",
                 "Должностные обязанности:\n",
                 "Требования к квалификации:\n"]

    text.each_line.inject("") { |new_text, line| new_text << (@titles.include?(line) ? "<h4>#{line.chomp}</h4>\n" : line) }
  end

  def self.convert_specs(specs)
    @ids_mapping ||= {
        911  => 4537,
        1    => 4274,
        5    => 4335,
        6    => 4408,
        16   => [4756, 4545],
        3    => 4488,
        9    => 4303,
        8    => 4649,
        547  => 4237,
        579  => 4237,
        1104 => 4671,
        10   => 4588,
        814  => 4568,
        2    => 4714,
        11   => 4671,
        13   => 4691,
        15   => 4649,
        17   => 4504,
        601  => 4428,
        45   => 4632,
        22   => 4473,
        515  => 4524,
        19   => 4473,
        20   => 4524,
        398  => 4749,
        503  => 4775,
        941  => 4742,
        1434 => 4802,
        2109 => 4537
    }
    specs.map { |i| @ids_mapping[i['thread'].to_i] }.to_a.flatten
  end

end


#MyCrawler.run        # => return Array 
#MyCrawler.run(:json) # => return String like a JSON object
#MyCrawler.run(:yaml) # => return String of YAML format