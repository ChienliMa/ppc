describe ::PPC::API::Qihu::Plan do
  auth = $baidu_auth

  test_plan_id = 0

  it ' can get all plan ids ' do
     response = ::PPC::API::Qihu::Plan::ids( auth )
     is_success( response )
     expect( response[:result].class ).to eq Array
  end

  it ' can get all plans ' do
     response = ::PPC::API::Qihu::Plan::all( auth )
     is_success( response )
     expect( response[:result].class ).to eq Array
  end

  it 'can add a plan' do
    response = ::PPC::API::Qihu::Plan::add( auth, {name:'planForTest'})
    is_success( response )
    test_plan_id = response[:result]
  end

  it 'can get a plan' do
    response = ::PPC::API::Qihu::Plan::get( auth, test_plan_id )
    is_success( response )
  end
  
  it 'can update a plan' do
    response = ::PPC::API::Qihu::Plan::update( auth, { id:test_plan_id, name:'planUpdateTest' } )
    is_success( response )
  end
  
  it 'can delete a plan ' do
    response = ::PPC::API::Qihu::Plan::delete( auth , test_plan_id  )
    is_success( response )
  end

end