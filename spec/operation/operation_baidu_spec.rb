require 'time'
require './operation_spec_helper'
  auth =  {}
  auth[:username] = $baidu_username
  auth[:password] = $baidu_password 
  auth[:token] = $baidu_token
  auth[:se] = 'baidu'
  preparation = ::PPC::API::Baidu::Group::ids( auth )
  test_plan_id = preparation[:result][0][:plan_id]
  test_group_id = preparation[:result][0][:group_ids][0]

describe ::PPC::Operation::Account do
  subject{
    ::PPC::Operation::Account.new( auth )
  }

  it_should_behave_like( "object", {budget:2990})
  it_should_behave_like( "object parent", 'plan')

  it_should_behave_like( "object operator", 'plan', {name:'operation_test_plan'},  
                         {name:'updated_operation_test_plan'})

  it_should_behave_like( "object operator", 'group', 
                          {name:'test_operation_group',plan_id:test_plan_id, price:500},
                          {name:'updated_operation_test_group'} )  

  it_should_behave_like( "object operator", 'keyword', 
                          { keyword:'testKeyword', group_id:test_group_id, match_type:'exact'},
                          { match_type:'wide'})

  it_should_behave_like( "object operator", 'creative', 
                         { group_id: test_group_id, 
                              title: 'OperationTestCreative', preference:1, 
                              description1:'this is rest',
                              description2:'also is a test',
                              pc_destination:$baidu_domain,
                              pc_display:$baidu_domain },
                         {title:'OperationTestCreative', 
                            description1:'this is a updated test',
                            pc_destination:$baidu_domain,
                            mobil_destination:$baidu_domain})
  
  # opetation report test
  it 'can get report' do
    endDate = Time.now.utc.iso8601
    startDate =( Time.now-30*3600*24).utc.iso8601
    pa = {startDate:startDate, endDate:endDate}
    subject.query_report(pa)
    subject.keyword_report(pa)
    subject.creative_report(pa)
  end
end

describe ::PPC::Operation::Plan do
  # get test subject
  subject{
    ::PPC::Operation::Plan.new( auth.merge({id:test_plan_id}) )
  }
  it_should_behave_like( "object", {budget:2000})
  it_should_behave_like( "object operator", 'group', 
                          {name:'test_operation_group', price:500},
                          {name:'updated_operation_test_group'} )  
  it_should_behave_like( "object parent", 'group')
end

describe ::PPC::Operation::Group do
  # get test subject
  subject{
    ::PPC::Operation::Group.new( auth.merge({id:test_group_id}) )
  }

  it_should_behave_like( "object", {price:200})
  it_should_behave_like( "object operator", 'keyword', 
                          { keyword:'testKeyword', group_id:test_group_id, match_type:'exact'},
                          { match_type:'wide'})
  it_should_behave_like( "object parent", 'keyword')
end

