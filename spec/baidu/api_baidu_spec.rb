require 'json'
require 'ppc/api/baidu/account'
describe ::PPC::API::Baidu do

  fake_response = "{\"header\":{\"desc\":\"success\",\"failures\":[],\"oprs\":1,\"oprtime\":0,
                                 \"quota\":2,\"rquota\":34047,\"status\":0},\"body\":{
                                  \"accountInfoType\":{\"userid\":5707012,\"balance\":0.0,\"cost\":0.0,
                                  \"payment\":0.0,\"budgetType\":1,\"budget\":3000.0,\"regionTarget\":[9999999],
                                  \"excludeIp\":[],\"openDomains\":[\"elong.com\"],\"regDomain\":\"elong.com\",
                                  \"budgetOfflineTime\":[],\"weeklyBudget\":[],\"userStat\":null,\"isDynamicCreative\":null,
                                    \"dynamicCreativeParam\":null,\"opt\":null}}}"

  response = JSON.parse fake_response

  expected_success_result = [:id, :balance, :cost, :payment, 
                                                :budget_type, :budget, :region, :exclude_ip, 
                                                :open_domains, :reg_domain, :offline_time, 
                                                :weekly_budget ]

  expected_failure_result = ["code", "message", "position", "content"] 

  it 'can process response' do
    response = ::PPC::API::Baidu::process( response, 'accountInfoType' ){|x| ::PPC::API::Baidu::Account::reverse_type(x)}
    expect( response[:result][0].keys ).to eq expected_success_result
  end

  # params for make_type and reverse_type test
  test_map = [
              [ :id , :campaignId],
              [ :name , :campaignName],
              [ :exclude_ip, :excludeIp],
              [ :exact_negative , :exactNegativeWords],
            ]

  test_type = {  }
  test_type['campaignId'] = 123
  test_type['campaignName'] = 'test_plan'
  test_type['excludeIp'] = [321,5432,52,1]
  test_type['exactNegativeWords'] = ['wu','liaode']

  test_param = { }
  test_param[ :id] = 123
  test_param[ :name] = 'testplan'
  test_param[ :exclude_ip] =  [321,5432,52,1]
  test_param[ :exact_negative] = ['wu','liaode']

  expected_type = [{:campaignId=>123, :campaignName=>"testplan", :excludeIp=>[321, 5432, 52, 1], :exactNegativeWords=>["wu", "liaode"]}]
  expexted_params = [{:id=>123, :name=>"test_plan", :exclude_ip=>[321, 5432, 52, 1], :exact_negative=>["wu", "liaode"]}]

  it 'can make and reverse type' do
    expect( ::PPC::API::Baidu::make_type( test_param , test_map) ).to eq expected_type
    expect( ::PPC::API::Baidu::reverse_type(test_type, test_map) ).to eq expexted_params
  end

end
