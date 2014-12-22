module PPC
  module API
    class Sogou
      class Account< Sogou
        Service = 'Account'

        @map = [
                [:id,:accountid],            
                [:balance,:balance],         
                [:cost,:totalCost],               
                [:payment,:totalPay],                          
                [:budget_type,:type],                   
                [:budget,:budget],                              
                [:region,:regions],                    
                [:exclude_ip,:excludeIps],                        
                [:open_domains,:domains],                  
                [:offline_time,:budgetOfflineTime],         
                [:opt,:opt]                                  
              ]

        def self.info(auth, debug = false)
          response = request(auth,Service,'getAccountInfo'  )
          return process( response, 'accountInfoType', debug ){ |x|reverse_type(x)[0] }
        end

        def self.update(auth, param = {}, debug = false)
          """
          update account info
          @ params : account_info_type
          @return : account info_type
          """
          # for account service, there is not bulk operation
          infoType = make_type( param )[0]
          body = { accountInfoType: infoType }
          response = request(auth,Service,'updateAccountInfo', body)
          return process( response, 'accountInfoType', debug ){ |x|reverse_type(x)[0] }
        end

      end
    end
  end
end
