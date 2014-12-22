# -*- coding:utf-8 -*-
describe ::PPC::API::Baidu::Creative do
  auth = $baidu_auth

  test_group_id = ::PPC::API::Baidu::Group::ids( auth )[:result][0][:group_ids][0]
  test_plan_id = ::PPC::API::Baidu::Plan::all( auth )[:result][0][:plan_id]
  test_creative_id = []

 it 'can add creative' do
    creative = { group_id: test_group_id, 
                        title: 'TestCreative', preference:1, 
                        description1:'this is rest',
                        description2:'also is a test',
                        pc_destination:$baidu_domain,
                        pc_display:$baidu_domain }
    response = ::PPC::API::Baidu::Creative::add( auth, creative )
    is_success( response )
    test_creative_id << response[:result][0][:id]
  end

  it 'can update creative' do
    update = { id:test_creative_id[0], 
                       title:'ElongUpdateTest',
                       description1:'test for update',
                        mobile_destination:$baidu_domain,
                        pc_destination:$baidu_domain,
                       pause:true} 
    response = ::PPC::API::Baidu::Creative::update( auth, update )
    is_success( response )
  end

  it 'can activate creative' do
    response = ::PPC::API::Baidu::Creative::activate( auth, test_creative_id )
    is_success( response )
  end

  # 连续测试的系统返回system_failured
  # it 'can get status' do
  #   response1 = ::PPC::API::Baidu::Creative::status( auth, test_group_id, 'group' )
  #   response2 = ::PPC::API::Baidu::Creative::status( auth, test_creative_id, 'creative' )
  #   response3 = ::PPC::API::Baidu::Creative::status( auth, test_plan_id, 'plan' )
  #   is_success( response1 ) 
  #   is_success( response2 ) 
  #   is_success( response3 ) 
  # end

  it 'can search id by group id' do
    response = ::PPC::API::Baidu::Creative::search_id_by_group_id( auth, test_group_id, 0 )
    is_success( response )
  end

  it 'can search creative by group id' do
    response = ::PPC::API::Baidu::Creative::search_by_group_id( auth, test_group_id, 0 )
    is_success( response )
  end

  it 'can search creative by creative id' do
    response = ::PPC::API::Baidu::Creative::get( auth, test_creative_id, 0 )
    is_success( response )
  end

  it 'can delete creative' do 
    response = ::PPC::API::Baidu::Creative::delete( auth, test_creative_id )
    is_success( response )
  end

end