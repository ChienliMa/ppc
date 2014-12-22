# -*- coding:utf-8 -*-
module PPC
  module API
    class Qihu
      class Keyword< Qihu
        Service = 'keyword'

        @map = [
                  [:id, :id],
                  [:group_id, :groupId],
                  [:keyword, :word],
                  [:price, :price],
                  [:match_type, :matchType],
                  [:pc_destination, :destinationUrl],
                  [:status, :status]
                ]

        @status_map = [ 
                        [:id,:id], 
                        [:quality,:qualityScore],
                        [:status,:status]
                      ]

        def self.get( auth, ids )
          ids = to_json_string( ids )
          body  = { 'idList' => ids }
          response = request( auth, Service, 'getInfoByIdList', body )
          process( response, 'keywordList'){ |x| reverse_type( x['item'] ) }
        end

        def self.add( auth,  keywords )
          keyword_types =  make_type( keywords ).to_json
          body = { 'keywords' => keyword_types}
          response = request( auth, Service, 'add', body )
          process( response, 'keywordIdList'){ |x| to_id_hash_list( x['item'] )  }
        end

        # helper function for self.add() method
        private
        def self.to_id_hash_list( str )
          reuturn [] if str == nil
          str = [str] unless str.is_a?Array
          x= []
          str.each{ |i| x << { id: i.to_i } }
          return x
        end

        def self.update( auth, keywords )
          keyword_types = make_type( keywords ).to_json
          body = { 'keywords' => keyword_types}
          response = request( auth, Service, 'update', body )
          process( response, 'affectedRecords', 'failKeywordIds' ){ |x| x }        
        end

        # 对update的再封装实现activate方法
        def self.activate( auth, ids )
          keywords = []
          ids.each{ |id| keywords << { id: id, status:'enable'} }
          update( auth, keywords )
        end

        def self.delete( auth, ids )
          body = { 'idList' => to_json_string( ids ) }
          response = request( auth, Service, 'deleteByIdList', body )
          process( response, 'affectedRecords' ){ |x|  x  }     
        end

        def self.status( auth, ids )
          body = { idList: to_json_string( ids ) }
          response = request( auth, Service, 'getStatusByIdList', body )
          process( response, 'keywordList' ){ |x| reverse_type( x['item'], @status_map ) }     
        end

        # quality 本质上和 status 在一个方法里面
        def self.quality( auth, ids )
          status( auth, ids)
        end
        
        def self.search_id_by_group_id( auth, id, status = nil, match_type = nil )
          # 处理条件  
          body = {}
          body['status'] = status if status
          body['matchType'] = match_type if match_type
          body['groupId'] = id
          response = request( auth, Service, 'getIdListByGroupId', body )
          # 伪装成百度接口
          process( response, 'keywordIdList' ){ 
            |x|
            [ { group_id:id, keyword_ids:to_id_list( x==nil ? nil: x['item'] ) } ]
          }     
        end

        # combine search_id and get to provide another method
        def self.search_by_group_id( auth, id )
          keyword_ids = search_id_by_group_id( auth, id )[:result][0][:keyword_ids]
          response = get( auth, keyword_ids )
          if response[:succ]
            # 伪装成百度接口
            response[:result] = [ { group_id:id, keywords:response[:result] } ]
          end
          return response
        end

        def self.getChangedIdList
          # unimplemented
        end

      end
    end
  end
end