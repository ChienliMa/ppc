describe ::PPC::API::Baidu::Plan do
  auth = $baidu_auth

  test_plan_id = []

  ::PPC::API::Baidu.debug_on

  it "can get all plans" do
    response = ::PPC::API::Baidu::Plan::all( auth )
    is_success( response )
  end

  it "can get all plan id" do 
    response = ::PPC::API::Baidu::Plan::ids( auth )
    is_success( response )
  end 

  it "can add plan" do
    test_plan = { name: "test_elong_e", negative: ["test"] }
    response = ::PPC::API::Baidu::Plan::add( auth, test_plan )
    is_success( response )
    test_plan_id << response[:result][0][:id]
  end

  it "can get plan by id" do
    response = ::PPC::API::Baidu::Plan::get( auth, test_plan_id )
    is_success( response )
  end

  it 'can update plan' do
    update = { id: test_plan_id[0], name:"test_plan_update", is_dynamic:false }
    response = ::PPC::API::Baidu::Plan::update( auth, update )
    # param isDynamicCreative should not be default value
    expect( response[:result][0][:is_dynamic] ).to eq false
    is_success( response )
  end

  it "can delete plan" do
    response = ::PPC::API::Baidu::Plan::delete( auth, test_plan_id )
    is_success( response )
  end

end
