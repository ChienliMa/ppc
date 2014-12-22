describe ::PPC::API::Baidu::Report do
  auth = $baidu_auth

  test_report_id = []

  it 'can get professional report id' do
    param = { type: 'plan', level:'plan',range:'plan',unit:'week',device:'all' }
    response = ::PPC::API::Baidu::Report::get_id( auth, param )
    is_success( response )
    test_report_id << response[:result]
  end

  it 'can get professional report status' do
    response = ::PPC::API::Baidu::Report::get_status( auth, test_report_id[0] )
    is_success( response )
  end

  # it 'can get professional report download URL' do
  #   response = ::PPC::API::Baidu::Report::get_file_url( auth, test_report_id[0] )
  #   is_success( response )
  # end
end

describe "::PPC::API::Baidu::Report useful fuction" do
  auth =  {}
  auth[:username] = $baidu_username
  auth[:password] = $baidu_password 
  auth[:token] = $baidu_token

  subject{
    ::PPC::API::Baidu::Report
  }
  # opetation report test
  it 'can get report' do
    endDate = ( Time.now-2*3600*24).to_s[0..9].split('-').join
    startDate =( Time.now-27*3600*24).to_s[0..9].split('-').join

    p "startDate:#{startDate}"
    p "endDate:#{endDate}"

    param = {startDate:startDate, endDate:endDate}
    subject.query_report( auth, param, true )
    subject.keyword_report( auth, param, true )
    subject.creative_report( auth,param, true )
  end

end
