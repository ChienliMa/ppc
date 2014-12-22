module PPC
  module API
    class Baidu
      class Plan< Baidu
        Service = 'Campaign'

        @map = [
                [:id,:campaignId],
                [:name,:campaignName],
                [:budget,:budget], 
                [:region,:regionTarget],
                [:ip,:excludeIp] ,
                [:negative,:negativeWords],
                [:exact_negative,:exactNegativeWords],
                [:schedule,:schedule], 
                [:budget_offline_time,:budgetOfflineTime],
                [:show_prob,:showProb],   
                [:device,:device],
                [:price_ratio,:priceRatio], 
                [:is_dynamic,:isDynamicCreative],
                [:pause,:pause],
                [:status,:status]
               ]

        def self.all( auth )
          response = request( auth, Service, 'getAllCampaign' )
          process( response, 'campaignTypes' ){ |x| reverse_type(x) }
        end

        def self.ids( auth )
          response = request( auth, Service, 'getAllCampaignId' )
          process( response, 'campaignIds' ){ |x| x }
        end

        def self.get( auth, ids )
          ids = [ ids ] unless ids.is_a? Array
          body = { campaignIds: ids }
          response = request( auth, Service, 'getCampaignByCampaignId', body)
          process( response, 'campaignTypes' ){ |x| reverse_type(x) }
        end

        def self.add( auth, plans )
          campaigntypes = make_type( plans )
          # set extended = 1 to allow change of isDynamicCreative
          body = { campaignTypes: campaigntypes, extended:1 }
          response = request( auth, Service, 'addCampaign', body)
          process( response, 'campaignTypes' ){ |x| reverse_type(x) }
        end

        def self.update(auth,plans )
          campaigntypes = make_type( plans )
          # set extended = 1 to allow change of isDynamicCreative
          body = { campaignTypes: campaigntypes, extended:1 }
          response = request( auth, Service, 'updateCampaign', body)
          process( response, 'campaignTypes' ){ |x| reverse_type(x) }
        end

        def self.delete(auth, ids )
          ids = [ ids ] unless ids.class == Array
          body = { campaignIds: ids }
          response = request( auth, Service, 'deleteCampaign', body)
          process( response, 'result' ){ |x| x }
        end
       
      end # Service
    end # baidu
  end # API
end # PPC