  auth =  {}
  auth[:username] = $baidu_username
  auth[:password] = $baidu_password 
  auth[:token] = $baidu_token
  auth[:se] = 'baidu'

describe ::PPC::Operation::Account do
  subject{
    ::PPC::Operation::Account.new( auth )
  }
  # opetation report test
  it 'can get report' do
    endDate = Time.now.to_s[0..9].split('-').join
    startDate =( Time.now-27*3600*24).to_s[0..9].split('-').join

    p "startDate:#{startDate}"
    p "endDate:#{endDate}"

    param = {startDate:startDate, endDate:endDate}
    subject.query_report( param, true )
    subject.keyword_report( param, true )
    subject.creative_report( param, true )
  end
end
