describe ::PPC::Operation::Account do
  subject{
    ::PPC::Operation::Account.new( $baidu_auth )
  }
  # opetation report test
  it 'can get report' do
    endDate = ( Time.now-2*3600*24).to_s[0..9].split('-').join
    startDate =( Time.now-27*3600*24).to_s[0..9].split('-').join

    p "startDate:#{startDate},endDate:#{endDate}"
    param = {startDate:startDate, endDate:endDate}

    subject.query_report( param, true )
    subject.keyword_report( param, true )
    subject.creative_report( param, true )
  end
end
