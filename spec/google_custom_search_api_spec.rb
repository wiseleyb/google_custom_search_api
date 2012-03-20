require File.dirname(__FILE__) + '/spec_helper'

describe "GoogleCustomSearchApi" do
  before :each do
    
  end
  
  it "should be able to run a poker search" do
    json = JSON.parse(File.read("#{File.dirname(__FILE__)}/fixtures/poker.json"))
    stub_request(:get, "https://www.googleapis.com/customsearch/v1?alt=json&cx=123&key=abc&q=poker").
      to_return(:status => 200, :body => json, :headers => {})
    res = GoogleCustomSearchApi.search("poker")
    res.items.size.should == 10
  end
  
  it "should be able to run an empty search" do
    json = JSON.parse(File.read("#{File.dirname(__FILE__)}/fixtures/empty.json"))
    stub_request(:get, "https://www.googleapis.com/customsearch/v1?alt=json&cx=123&key=abc&q=asdfqwerzxcvr").
      to_return(:status => 200, :body => json, :headers => {})
    res = GoogleCustomSearchApi.search("asdfqwerzxcvr")
    res.items.size.should == 0
  end
  
  it "should be able to alter start" do
    json = JSON.parse(File.read("#{File.dirname(__FILE__)}/fixtures/poker_81.json"))
    stub_request(:get, "https://www.googleapis.com/customsearch/v1?alt=json&cx=123&key=abc&q=poker&start=81").
       to_return(:status => 200, :body => json, :headers => {})
    res = GoogleCustomSearchApi.search("poker", :start => 81)
    res.items.size.should == 10
  end
  
  it "should be able to get all results" do
    json1 = JSON.parse(File.read("#{File.dirname(__FILE__)}/fixtures/poker_81.json"))
    stub_request(:get, "https://www.googleapis.com/customsearch/v1?alt=json&cx=123&key=abc&q=poker&start=81").
       to_return(:status => 200, :body => json1, :headers => {})
       
    json2 = JSON.parse(File.read("#{File.dirname(__FILE__)}/fixtures/poker_91.json"))
    stub_request(:get, "https://www.googleapis.com/customsearch/v1?alt=json&cx=123&key=abc&q=poker&start=91").
      to_return(:status => 200, :body => json2, :headers => {})
      
    res = GoogleCustomSearchApi.search_and_return_all_results("poker", :start => 81)
    res.first.queries.nextPage.first.startIndex.to_s.should == "91"
    res.last.queries.keys.include?("nextPage").should == false
  end
  
end