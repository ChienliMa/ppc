describe ::PPC::API::Sogou::Report do
  auth = $sogou_auth

  param = {} 
  param[:type]   = 'query'
  param[:fields] =  %w(click impression)
  param[:level]  = 'pair'
  param[:range]  = 'account'
  param[:unit]   = 'day'

  it "can get report id" do
    response = ::PPC::API::Sogou::Report.get_id( auth, param )
    p response
  end

  it "can get report state" do
    response = ::PPC::API::Sogou::Report.get_state( auth, 'fdsafdsfafdsaf' )
  end

  it "can get report url" do
  end

  it "can download one report" do
  end

  it "can download query report" do
  end

  it "can download keyword report" do
  end

  it "can download creative report" do
  end

end