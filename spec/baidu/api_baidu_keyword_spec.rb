# -*- coding:utf-8 -*-
describe ::PPC::API::Baidu::Keyword do
  auth = $baidu_auth

  test_group_id = ::PPC::API::Baidu::Group::ids( auth )[:result][0][:group_ids][0]
  test_plan_id = ::PPC::API::Baidu::Plan::all( auth )[:result][0][:plan_id]
  test_keyword_id = []

  it 'can search keyword by group id' do
    response = ::PPC::API::Baidu::Keyword::search_by_group_id( auth, test_group_id )
    is_success( response )
  end

  it 'can add keyword' do
    keyword = { group_id: test_group_id, keyword: 'testkeywordid', match_type:'exact' }
    response = ::PPC::API::Baidu::Keyword::add( auth, keyword )
    is_success( response )
    test_keyword_id << response[:result][0][:id]
  end

  it 'can update keyword' do
    update = { id:test_keyword_id[0],  pc_destination: $baidu_domain, pause:true} 
    response = ::PPC::API::Baidu::Keyword::update( auth, update )
    is_success( response )
  end

  it 'can activate keyword' do
    response = ::PPC::API::Baidu::Keyword::activate( auth, test_keyword_id )
    is_success( response )
  end

  # 连续测试系统返回system failure
  # it 'can get status' do
  #   response1 = ::PPC::API::Baidu::Keyword::status( auth, test_group_id, 'group' )
  #   response2 = ::PPC::API::Baidu::Keyword::status( auth, test_keyword_id, 'keyword' )
  #   response3 = ::PPC::API::Baidu::Keyword::status( auth, test_plan_id, 'plan' )
  #   is_success( response1 ) 
  #   is_success( response2 ) 
  #   is_success( response3 ) 
  # end

  # it 'can get quality' do
  #   response1 = ::PPC::API::Baidu::Keyword::quality( auth, test_group_id, 'group', true )
  #   response2 = ::PPC::API::Baidu::Keyword::quality( auth, test_keyword_id, 'keyword', true )
  #   response3 = ::PPC::API::Baidu::Keyword::quality( auth, test_plan_id, 'plan', true )
  #   is_successed( response1 ) 
  #   is_successed( response2 ) 
  #   is_successed( response3 ) 
  # end

  it 'can get 10-quality' do
    response = ::PPC::API::Baidu::Keyword::quality( auth, test_keyword_id, 'keyword', 'pc' )
    is_success( response )    
  end

  it 'can delete keyword' do
    response = ::PPC::API::Baidu::Keyword::delete( auth, test_keyword_id )
    is_success( response )
  end

end
