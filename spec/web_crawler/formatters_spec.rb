require "spec_helper"


describe WebCrawler::Formatter::CSV do

  let(:input) { [[1, 2, "3"], ["string", "other string\n"]] }
  let(:input_hash) { [{ :title=>1, :url=>2, :author=>3 }, { :title=>"string", :url=>"other string\n" }] }

  it "should format input array to csv string" do
    described_class.new(input).process.should == "1,2,3\nstring,\"other string\n\"\n"
  end

  it "should format input hash to csv string" do
    described_class.new(input_hash).process.should == "title,url,author\n1,2,3\nstring,\"other string\n\"\n"
  end

  it "should format input array to csv string with options" do
    described_class.new(input, headers: [:title, :url, :author], col_sep: ";").process.should == "title;url;author\n1;2;3\nstring;\"other string\n\"\n"
    described_class.new(input, headers: [:title, :url, :author], row_sep: "\n\n").process.should == "title,url,author\n\n1,2,3\n\nstring,\"other string\n\"\n\n"
  end

end

describe WebCrawler::Formatter::JSON do

  let(:input) { [[1, 2, "3"], ["string", "other string\n"]] }
  let(:input_hash) { [{ :title=>1, :url=>2, :author=>3 }, { :title=>"string", :url=>"other string\n", :author=>nil }] }

  it "should format input array to json string" do
    described_class.new(input, headers: [:title, :url, :author]).process.should == '{"responses":[[1,2,"3"],["string","other string\n"]]}'
  end

  it "should format input hash to json string" do
    json = described_class.new(input_hash).process
    json.should == "{\"responses\":[{\"title\":1,\"url\":2,\"author\":3},{\"title\":\"string\",\"url\":\"other string\\n\",\"author\":null}]}"
    hash = JSON.parse(json).symbolize_keys
    hash[:responses].each(&:symbolize_keys!)
    hash.should == {responses: input_hash}
  end
end


describe WebCrawler::Formatter::XML do

  let(:input) { [[1, 2, "3"], ["string", "other string\n"]] }
  let(:input_hash) { [{ :title=>1, :url=>2, :author=>3 }, { :title=>"string", :url=>"other string\n", :author=>nil }] }

  it "should format input array to xml string" do
    xml = "<responses>" <<
        "<response><title>1</title><url>2</url><author>3</author></response>" <<
        "<response><title>string</title><url>other string\n</url><author></author></response>" <<
        "</responses>"
    described_class.new(input, headers: [:title, :url, :author]).process.should == xml
  end

  it "should format input array to pretty xml string" do
    xml = "<responses>\n" <<
        "<response><title>1</title><url>2</url><author>3</author></response>\n" <<
        "<response><title>string</title><url>other string\n</url><author></author></response>\n" <<
        "</responses>"
    described_class.new(input, headers: [:title, :url, :author], pretty: true).process.should == xml
  end

  it "should format input array without :headers to xml string" do
    xml = "<responses>\n" <<
        "<response><field_1>1</field_1><field_2>2</field_2><field_3>3</field_3></response>\n" <<
        "<response><field_1>string</field_1><field_2>other string\n</field_2><field_3></field_3></response>\n" <<
        "</responses>"
    described_class.new(input, pretty: true).process.should == xml
  end

  it "should format input hash to xml string" do
    xml = "<responses>\n" <<
        "<response><title>1</title><url>2</url><author>3</author></response>\n" <<
        "<response><title>string</title><url>other string\n</url><author></author></response>\n" <<
        "</responses>"
    described_class.new(input_hash, pretty: true).process.should == xml
  end
end