require "spec_helper"


describe WebCrawler::View::Csv do

  let(:input) { [[1, 2, "3"], ["string", "other string\n"]] }
  let(:input_hash) { [{ :title=>1, :url=>2, :author=>3 }, { :title=>"string", :url=>"other string\n" }] }

  it "should render input array to csv string" do
    described_class.new(input).render.should == "1,2,3\nstring,\"other string\n\"\n"
  end

  it "should render input hash to csv string" do
    described_class.new(input_hash).render.should == "title,url,author\n1,2,3\nstring,\"other string\n\"\n"
  end

  it "should render input array to csv string with options" do
    described_class.new(input, headers: [:title, :url, :author], col_sep: ";").render.should == "title;url;author\n1;2;3\nstring;\"other string\n\"\n"
    described_class.new(input, headers: [:title, :url, :author], row_sep: "\n\n").render.should == "title,url,author\n\n1,2,3\n\nstring,\"other string\n\"\n\n"
  end

end

describe WebCrawler::View::Json do

  let(:input) { [[1, 2, "3"], ["string", "other string\n"]] }
  let(:input_hash) { [{ :title=>1, :url=>2, :author=>3 }, { :title=>"string", :url=>"other string\n", :author=>nil }] }

  it "should render input array to json string" do
    described_class.new(input, headers: [:title, :url, :author]).render.should == '{"responses":[[1,2,"3"],["string","other string\n"]]}'
  end

  it "should render input hash to json string" do
    json = described_class.new(input_hash).render
    json.should == "{\"responses\":[{\"title\":1,\"url\":2,\"author\":3},{\"title\":\"string\",\"url\":\"other string\\n\",\"author\":null}]}"
    hash = JSON.parse(json).symbolize_keys
    hash[:responses].each(&:symbolize_keys!)
    hash.should == { responses: input_hash }
  end
end


describe WebCrawler::View::Xml do

  let(:input) { [[1, 2, "3"], ["string", "other string\n"]] }
  let(:input_hash) { [{ :title=>1, :url=>2, :author=>3 }, { :title=>"string", :url=>"other string\n", :author=>nil }] }

  it "should render input array to xml string" do
    xml = "<responses>" <<
        "<response><title>1</title><url>2</url><author>3</author></response>" <<
        "<response><title>string</title><url>other string\n</url><author></author></response>" <<
        "</responses>"
    described_class.new(input, headers: [:title, :url, :author]).render.should == xml
  end

  it "should render input array to pretty xml string" do
    xml = "<responses>\n" <<
        "<response><title>1</title><url>2</url><author>3</author></response>\n" <<
        "<response><title>string</title><url>other string\n</url><author></author></response>\n" <<
        "</responses>"
    described_class.new(input, headers: [:title, :url, :author], pretty: true).render.should == xml
  end

  it "should render input array without :headers to xml string" do
    xml = "<responses>\n" <<
        "<response><field_1>1</field_1><field_2>2</field_2><field_3>3</field_3></response>\n" <<
        "<response><field_1>string</field_1><field_2>other string\n</field_2><field_3></field_3></response>\n" <<
        "</responses>"
    described_class.new(input, pretty: true).render.should == xml
  end

  it "should render input hash to xml string" do
    xml = "<responses>\n" <<
        "<response><title>1</title><url>2</url><author>3</author></response>\n" <<
        "<response><title>string</title><url>other string\n</url><author></author></response>\n" <<
        "</responses>"
    described_class.new(input_hash, pretty: true).render.should == xml
  end
end

describe WebCrawler::View do

  it "should factory a view from view type" do
    WebCrawler::View.factory('json', [1, 2, 3]).should be_a WebCrawler::View::Json
    WebCrawler::View.factory('xml', [1, 2, 3]).should be_a WebCrawler::View::Xml
    WebCrawler::View.factory('table', [1, 2, 3]).should be_a WebCrawler::View::Table
  end

  it "should draw view to custom output" do
    output = ""
    io = StringIO.new(output)
    WebCrawler::View.factory('json', [[1, 2, 3]]).draw(io)
    output.should == "{\"responses\":[[1,2,3]]}\n"
  end
end