describe ::PPC::API::Qihu::Report do
  auth = $baidu_auth

  # param for test    

  # all method of query return 403 forbidden
  type_list = ['keyword',  'creative', 'sublink']
  method_list = ['','_now','_now_count','_count']

  startDate = (Time.now - 5*24*3600).to_s[0...10].split('-').join
  endDate = (Time.now - 2*24*3600).to_s[0...10].split('-').join
  param = {level:"account", startDate:startDate, endDate:endDate}

  ############################
  # test for Web Service API #
  ############################
  it "has an workable abstract function" do
    response = ::PPC::API::Qihu::Report.abstract( auth,'keyword','keywordNowCount','',{})
    expect(response[:result][0].keys).to eq [:total_num,:total_page]
  end

  it "have all methods for each report type" do
    method_list.each do |method|
      type_list.each do |type|
        method_name = type+method
        method_name = method_name.to_sym
        p ::PPC::API::Qihu::Report.send( method_name, auth, param)
        # is_success( response )
      end
    end
  end

  ################################
  # test for Operation interface #
  ################################
  it 'can download report' do
    report = ::PPC::API::Qihu::Report.download_report( auth, 'keyword', param )
  end

  it 'can download keyword report' do
    report = ::PPC::API::Qihu::Report.keyword_report( auth, param )
    f = open('keyword.txt','w')
    f.puts report
    f.close
  end

  it 'can download creative report' do
    report = ::PPC::API::Qihu::Report.creative_report( auth, param )
        f = open('creative.txt','w')
    f.puts report
    f.close
  end

end
