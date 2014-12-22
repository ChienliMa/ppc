describe ::PPC::API::Qihu::Keyword do
  auth = $baidu_auth

  test_plan_id = ::PPC::API::Qihu::Plan::ids( auth )[:result][0].to_i
  test_group_id = ::PPC::API::Qihu::Group::search_id_by_plan_id( auth, test_plan_id )[:result][0][:group_ids][0]to_i
  test_keyword_id = 0

  it 'can search keyword id by group id' do
    response = ::PPC::API::Qihu::Keyword::search_id_by_group_id( auth, test_group_id )
    is_success( response)
    expect( response[:result].class ).to eq Array
  end

  it 'can search keyword by group id' do
    response = ::PPC::API::Qihu::Keyword::search_by_group_id( auth, test_group_id )
    is_success( response)
    expect( response[:result].class ).to eq Array
  end

  it 'can add keyword' do
    keyword1 = { group_id:test_group_id, keyword:"testKeyword1",price:0.3,match_type:"exact"}
    response =  ::PPC::API::Qihu::Keyword::add( auth, keyword1)
    is_success( response )
    test_keyword_id = response[:result][0]
    p response
  end

  it 'can update keyword' do
     keyword = { id:test_keyword_id, price:0.4 }
     response =  ::PPC::API::Qihu::Keyword::update( auth, keyword )
     is_success( response )
  end 

  it 'can get keyword' do
    response =  ::PPC::API::Qihu::Keyword::get( auth, test_keyword_id )
    is_success( response )
    expect( response[:result][0].keys ).to include( :id, :status )
  end

  it 'can get status' do
      response =  ::PPC::API::Qihu::Keyword::status( auth, test_keyword_id )
      is_success( response )
  end

  it 'can delete keyword' do
      response =  ::PPC::API::Qihu::Keyword::delete( auth, test_keyword_id )
      is_success( response )
  end
  
end