describe ::PPC::API::Baidu::Account do
  auth = $baidu_auth
  
  it 'can get account info' do
      result = ::PPC::API::Baidu::Account::info( auth )
      is_success( result )
  end

  it 'can update account' do
    update = {budget:2990}
    result =  ::PPC::API::Baidu::Account::update( auth, update )
    is_success( result )
  end

end
