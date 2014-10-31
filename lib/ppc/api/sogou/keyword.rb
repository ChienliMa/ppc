# -*- coding:utf-8 -*-
module PPC
  module API
    class Sogou
      class Keyword< Sogou
        Service = 'Cpc'

        Match_type  = { 'exact' => 0, 'wide' => 1 }
        Match_type_r  = { 0 => 'exact', 1 => 'wide' }
                
        @map  = [
                            [:id,:cpcId],
                            [:group_id,:cpcGrpId],
                            [:keyword,:cpc],
                            [:price,:price],
                            [:pc_destination,:visitUrl],
                            [:mobile_destination,:mobileVisitUrl],
                            [:match_type,:matchType],
                            [:pause,:pause],
                            [:status,:status],
                            [:quality,:cpcQuality]
                        ]

        # 后面改成info方法
        def self.get( auth, ids, debug = false )
          '''
          getCpcByCpcId
          '''
          ids = [ ids ] unless ids.is_a? Array
          body = { cpcIds: ids}
          response = request( auth, Service, 'getCpcByCpcId', body )
          return process(response, 'cpcTypes', debug){|x| reverse_type( x ) }
        end

        def self.add( auth, keywords, debug = false )
          '''
          '''
          cpcTypes = make_type( keywords ) 
          body = { cpcTypes: cpcTypes }
          response = request( auth, Service, "addCpc", body )
          return process(response, 'cpcTypes', debug){|x| reverse_type(x)  }
        end

        def self.update( auth, keywords, debug = false  )
          '''
          '''
          cpcTypes = make_type( keywords ) 
          body = { cpcTypes: cpcTypes }
          response = request( auth, Service, "updateCpc", body )
          p response
          return process(response, 'cpcTypes', debug){|x| reverse_type(x)  }
        end

        def self.delete( auth, ids, debug = false )
          """
          """
          ids = [ ids ] unless ids.is_a? Array
          body = { cpcIds: ids}
          response = request( auth, Service, 'deleteCpc', body )
          return process(response, 'nil', debug){|x| x }
        end

        def self.search_by_group_id( auth, group_ids, debug = false  )
          """
          getKeywordByGroupIds
          @input: list of group id
          @output:  list of groupKeyword
          """
          group_ids = [ group_ids ] unless group_ids.is_a? Array
          body = { cpcGrpIds: group_ids }
          response = request( auth, Service, "getCpcByCpcGrpId", body )
          return process(response, 'cpcGrpCpcs', debug){|x| make_groupKeywords( x ) }
        end

        def self.search_id_by_group_id( auth, group_ids, debug = false  )
          group_ids = [ group_ids ] unless group_ids.is_a? Array
          body = { cpcGrpIds: group_ids }
          response = request( auth, Service, "getCpcIdeaByCpcGrpId", body )
          return process(response, 'cpcGrpCpcIds', debug){|x| make_groupKeywordIds( x ) }
        end

        # sogou的keyword服务不提供质量度
        def self.status( auth, ids, type, debug = false )
          '''
          Return [ { id: id, status: status} ... ]
          '''
          ids = [ ids ] unless ids.is_a? Array
          body = { ids: ids, type: Type[type]}
          
          info_result = get( ids )
          result = {}
          result[:succ] = info_result[:succ]
          result[:failure] = info_result[:failure]
          # extract status informantion
          status = []
          info_result[:result].each do |cpc_type|
            status << { id:cpc_type[:id], status:cpc_type[:status]}
          end
          result[:result] = status
          
          return result
        end

        def self.quality( auth ,ids, type, device, debug = false )
          '''
          Return [ { id: id, quality: quality} ... ]
          '''
          ids = [ ids ] unless ids.is_a? Array
          body = { ids: ids, type: Type[type]}
          
          info_result = get( ids )
          result = {}
          result[:succ] = info_result[:succ]
          result[:failure] = info_result[:failure]
          # extract status informantion
          quality = []
          info_result[:result].each do |cpc_type|
            quality << { id:cpc_type[:id], quality:cpc_type[:quality]}
          end
          result[:result] = quality
          
          return result
        end

        private
        def self.make_groupKeywordIds( cpcGrpCpcIdTypes )
          cpcGrpCpcIdTypes = [cpcGrpCpcIdTypes] unless cpcGrpCpcIdTypes.is_a? Array
          group_keyword_ids = []
          cpcGrpCpcIdTypes.each do |cpcGrpCpcIdType|
            group_keyword_id = { }
            group_keyword_id[:group_id] = cpcGrpCpcIdType[:cpc_grp_id]
            group_keyword_id[:keyword_ids] = cpcGrpCpcIdType[:cpc_ids]
            group_keyword_ids << group_keyword_id
          end
          return group_keyword_ids
        end

        private
        def self.make_groupKeywords( cpcGrpCpcTypes )
          cpcGrpCpcTypes = [cpcGrpCpcTypes] unless cpcGrpCpcTypes.is_a? Array 
          group_keywords = []
          cpcGrpCpcTypes.each do |cpcGrpCpcType|
            group_keyword = {}
            group_keyword[:group_id] = cpcGrpCpcType[:cpc_grp_id]
            group_keyword[:keywords] = reverse_type( cpcGrpCpcType[:cpc_types] )
            group_keywords << group_keyword
          end
          return group_keywords
        end

        # Override
       def self.make_type( params, map = @map)
          params = [ params ] unless params.is_a? Array
          types = []
          params.each do |param|
            type = {}
              map.each do |key|
                # 增加对matchtype的自动转换
                if key[0] == :match_type
                   value = param[ key[0] ]
                  type[ key[1] ] = Match_type[ value ] if value                 
                else
                  value = param[ key[0] ]
                  type[ key[1] ] = value if value
                end
              end
            types << type
          end
          return types
        end

        # Overwrite
        def self.reverse_type( types, map = @map )
          types = [ types ] unless types.is_a? Array
          params = []
          types.each do |type|
            param = {}
             # 增加对matchtype的自动转换
              map.each do |key|
                if key[0] == :match_type
                   value = type[ key[1].to_s.snake_case.to_sym]
                  param[ key[0] ] = Match_type_r[ value ] if value                 
                else
                  value = type[ key[1].to_s.snake_case.to_sym ]
                  param[ key[0] ] = value if value
                end
              end # map.each
            params << param
          end # types.each
          return params
        end

      end # keyword
    end # Baidu
  end # API
end # PPC