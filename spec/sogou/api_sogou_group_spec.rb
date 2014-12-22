describe ::PPC::API::Sogou::Group do
  auth = $sogou_auth

  test_plan_id = ::PPC::API::Sogou::Plan.ids(auth)[:result][0]
  test_group_id = []

  it 'can get all group' do 
    response = ::PPC::API::Sogou::Group::ids( auth )
    is_success( response ) 
  end

  it 'can add group' do 
    group = { name: 'test_group', plan_id:test_plan_id, price:500 }
    response = ::PPC::API::Sogou::Group::add( auth, group )
    is_success( response )
    test_group_id << response[:result][0][:id]
  end
  
  it 'can update group' do 
    group = { id: test_group_id[0], price:600 }
    response = ::PPC::API::Sogou::Group::update( auth, group )
    is_success( response )
  end

  it 'can search group by group id' do
    response = ::PPC::API::Sogou::Group::get( auth, test_group_id )
    is_success( response )
  end
  
  it 'can search group id by plan id' do
    response = ::PPC::API::Sogou::Group::search_id_by_plan_id( auth, test_plan_id )
    is_success( response )
  end

  it 'search by plan id' do 
    response = ::PPC::API::Sogou::Group::search_by_plan_id( auth, test_plan_id )
    is_success( response )
  end  

  it 'can delete group' do 
    response = ::PPC::API::Sogou::Group::delete( auth, test_group_id )
    is_success( response )
  end
  
end
