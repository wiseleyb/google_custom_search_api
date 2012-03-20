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
  
end