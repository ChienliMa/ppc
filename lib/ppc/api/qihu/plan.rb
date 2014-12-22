# -*- coding:utf-8 -*-
module PPC
  module API
    class Qihu
      class Plan < Qihu
        Service = 'campaign'

        @map = [
                  [:id, :id],
                  [:name,:name],
                  [:budget, :budget],
                  [:region, :region],
                  [:schedule, :schedule],
                  [:startDate, :startDate],
                  [:endDate, :endDate ],
                  [:status,:status], 
                  [:extend_ad_type,:extendAdType]
                ]


        def self.get( auth, ids )
          '''
          :Type ids: ( Array of ) String or integer
          '''
          ids = to_json_string( ids )    
          body = { ' idList' =>  ids  }
          response = request( auth, Service, 'getInfoByIdList', body )
          process( response, 'campaignList' ){ |x| reverse_type( x['item'] ) }
        end

        # move getCampaignId to plan module for operation call
        def self.ids( auth )
          response = request( auth, 'account', 'getCampaignIdList' )
          process( response, 'campaignIdList' ){ |x| to_id_list( x['item'])}
        end 

        # combine two original method to provice new method
        def self.all( auth )
          plan_ids = ids( auth )[:result]
          get( auth, plan_ids )
        end
        
        # 奇虎计划API不提供批量服务
        def self.add( auth, plan )
          response = request( auth, Service, 'add', make_type( plan )[0])
          # 这里将返回的简单int做一个array和hash的封装一保证接口和百度，搜狗的一致性
          process( response, 'id' ){ |x| [ { id:x.to_i } ] }
        end

        def self.update( auth, plan ) 
           response = request( auth, Service, 'update', make_type( plan )[0])
           #同上，保证接口一致性
           process( response, 'id' ){ |x| [ { id:x.to_i } ] }
        end

        def self.delete( auth, id )
          response = request( auth, Service, 'deleteById', { id: id } )
          process( response, 'affectedRecords' ){ |x|  x == '1'? 'success' : 'fail' }
        end

      end
    end
  end
end