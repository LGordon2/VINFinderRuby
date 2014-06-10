require 'rspec'
require 'rspec/expectations'

require File.expand_path('../../lib/params',__FILE__)

describe URI do
  it "should add params to existing query" do
    uri = URI('http://www.ebay.com/sch/Cars-Trucks-/6001/i.html?_dcat=6001&_momoc=1&_rdc=1')
    uri.set_params('_pgn' => 1)
    expect(uri.query).to eq('_dcat=6001&_momoc=1&_rdc=1&_pgn=1')
  end

  it "should add params to non-existing query" do
    uri = URI('http://www.ebay.com/sch/Cars-Trucks-/6001/i.html')
    uri.set_params('_pgn' => 1)
    expect(uri.query).to eq('_pgn=1')
  end
  
  it "should set value of param in query" do
    uri = URI('http://www.ebay.com/sch/Cars-Trucks-/6001/i.html?_dcat=6001&_momoc=1&_rdc=1&_pgn=1')
    uri.set_params('_pgn' => 5)
    expect(uri.query).to eq('_dcat=6001&_momoc=1&_rdc=1&_pgn=5')
  end
end
