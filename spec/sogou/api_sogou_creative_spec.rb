# -*- coding:utf-8 -*-
describe ::PPC::API::Sogou::Creative do
  '''
  sogou的创意服务在add的时候需要审核因此自动测试不能一次通过，
  会出现Creative is pending的error.不过手动测试方法没问题了。
  '''
  auth = $sogou_auth

  # prepare for test param
  ::PPC::API::Sogou.debug_off
  test_group_id = ::PPC::API::Sogou::Group::ids( auth )[:result][0][:group_ids][0]
  test_creative_id = []
  ::PPC::API::Sogou.debug_on

  it 'can search Creative by group id' do
    response = ::PPC::API::Sogou::Creative::search_by_group_id( auth, test_group_id )
    is_success( response )
  end

  it 'can add Creative' do
    Creative = { group_id: test_group_id, title: 'testCreative', 
                        description1:"this is a test", description2: "this is another test",
                        pc_destination:$sogou_domain, pc_display:$sogou_domain }
    response = ::PPC::API::Sogou::Creative::add( auth, Creative )
    is_success( response )
    p response
    test_creative_id << response[:result][0][:id]
  end

  it 'can get status' do
    response = ::PPC::API::Sogou::Creative::status( auth, test_creative_id)
    is_success(response)
    expect(response[:result][0].keys).to eq [:id,:status]
  end

  it 'can update Creative' do
    update = { id:test_creative_id,  description1: 'sogou_expiediction', pause:true} 
    response = ::PPC::API::Sogou::Creative::update( auth, update )
    p response
    is_success( response )
  end

  it 'can delete Creative' do
    response = ::PPC::API::Sogou::Creative::delete( auth, test_creative_id )
    is_success( response )
  end

end
