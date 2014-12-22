# -*- coding:utf-8 -*-
module PPC
  module API
    class Qihu
      class Group < Qihu
        Service = 'group'

        @map = [
                [:id, :id ],
                [:plan_id, :campaignId],
                [:status, :status ],
                [:name, :name ],
                [:price, :price ],
                # negateive为json格式，make_type要定制
                [:negative, :negativeWords ],
                [:add_time, :addTime],
                [:update_time, :updateTime]
               ]

        # 再次封装提供all和ids
        def self.ids( auth )
          '''
          接口与其他的相同，但是无论如何：succ均为true，不返回任何错误信息
          因为是重复调用了search的接口，速度非常的慢，* 慎用 *
          '''
          plan_ids = ::PPC::API::Qihu::Plan::ids( auth )[:result]
          plan_group_ids = []

          plan_ids.each do |plan_id|
            plan_group_id = {}
            plan_group_id[:plan_id] = plan_id
            plan_group_id[:group_ids] = search_id_by_plan_id( auth, plan_id )[:result]
            plan_group_ids << plan_group_id
          end
          return { succ: true, failure:nil, result: plan_group_ids }
        end

        def self.all( auth )
          '''
          unimplemented due to ineffciency
          '''
          # unimplement
        end

        # 奇虎组服务不提供批量add,delete和update方法
        def self.add( auth, group )
          response = request( auth, Service, 'add', make_type( group )[0] )
          # 保证接口一致性
          process( response, 'id' ){ |x| [ { id:x.to_i } ]    }
        end
        
        def self.update( auth, group )
          response = request( auth, Service, 'update', make_type( group )[0]  )
          # 保证接口一致性
          process( response, 'id' ){ |x|[ { id:x.to_i } ]  }
        end

        def self.get( auth, ids )
          ids = to_json_string( ids )
          body = { 'idList' => ids }
          response = request( auth, Service, 'getInfoByIdList', body  )
          process( response, 'groupList' ){ |x| reverse_type( x['item'] ) }
        end

        def self.delete( auth, id )
          response = request( auth, Service, 'deleteById', { id: id}  )
          process( response, 'affectedRecords' ){ |x| x == '1' }
        end
      
        def self.search_id_by_plan_id( auth, id )
          response = request( auth, Service, 'getIdListByCampaignId', { 'campaignId' => id.to_s })
          #为了保持接口一致性，这里也是伪装成了百度的接口
          process( response, 'groupIdList' ){ 
            |x|
             [ { plan_id:id, group_ids: to_id_list( x==nil ? nil: x['item'] ) } ]
           }
        end

        # combine searchIdbyId and get to provide another method
        def self.search_by_plan_id( auth, id )
          group_ids = search_id_by_plan_id( auth, id )[:result][0][:group_ids]
          response = get( auth, group_ids )
          if response[:succ]
            response[:result] = [ { plan_id:id, groups:response[:result]}]
          end
          return response
        end

      # customize make type to convert negative word
      def self.make_type( params, map = @map)
        '''
        '''
        params = [ params ] unless params.is_a? Array

        types = []
        params.each do |param|
          type = {}

            map.each do |key|
              # next line transfer negative param to json
              key[0]==:negative&&param[:negative] ? value=param[:negative].to_json : value=param[key[0]]
              type[ key[1] ] = value if value != nil
            end

          types << type
        end
        return types
      end

      end
    end
  end
end