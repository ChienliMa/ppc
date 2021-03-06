# -*- coding:utf-8  -*-
module PPC
  module API
    class Sogou
      class Group< Sogou
        Service = 'CpcGrp'

        @map =[
                        [:plan_id, :cpcPlanId],
                        [:id, :cpcGrpId],
                        [:name, :cpcGrpName],
                        [:price, :maxPrice],
                        [:negative, :negativeWords],
                        [:exact_negative, :exactNegativeWords],
                        [:pause, :pause],
                        [:status, :status],
                        [:opt, :opt]
                      ]

        def self.ids(auth, debug = false )
          """
          @return : Array of cpcPlanGrpIdTypes
          """
          response = request( auth, Service , "getAllCpcGrpId" )
          #此处返回值与key与开发文档不同
          process( response, 'cpcPlanGrpIds', debug ){ |x| make_planGroupIds( x ) }
        end

        def self.get( auth, ids, debug = false )
          ids = [ ids ] unless ids.is_a? Array
          body = { cpcGrpIds: ids }
          response = request(auth, Service, "getCpcGrpByCpcGrpId",body )
          process( response, 'cpcGrpTypes', debug ){ |x| reverse_type(x) }
        end

        def self.add( auth, groups, debug = false )
          """
          @ input : one or list of AdgroupType
          @ output : list of AdgroupType
          """
          cpcGrpTypes = make_type( groups )

          body = {cpcGrpTypes:  cpcGrpTypes }
          
          response = request( auth, Service, "addCpcGrp", body  )
          process( response, 'cpcGrpTypes', debug ){ |x| reverse_type(x) }
        end

        def self.update( auth, groups, debug = false )
          """
          @ input : one or list of AdgroupType
          @ output : list of AdgroupType
          """
          cpcGrpTypes = make_type( groups )
          body = {cpcGrpTypes: cpcGrpTypes}
          
          response = request( auth, Service, "updateCpcGrp",body )
          process( response, 'cpcGrpTypes', debug ){ |x| reverse_type(x) }
        end

        def self.delete( auth, ids, debug = false )
          """
          delete group body has no message
          """
          ids = [ ids ] unless ids.is_a? Array
          body = { cpcGrpIds: ids }
          response = request( auth, Service,"deleteCpcGrp", body )
          process( response, 'nil', debug ){ |x|  x  }
        end

        def self.search_by_plan_id( auth, ids, debug = false )
          ids = [ ids ] unless ids.is_a? Array
          body = { cpcPlanIds: ids }
          response = request( auth, Service ,"getCpcGrpByCpcPlanId",  body )
          # 此处key与开发文档不同
          process( response, 'cpcPlanGrps', debug ){ |x| make_planGroups( x ) }
        end

        def self.search_id_by_plan_id( auth, ids, debug = false )
          ids = [ ids ] unless ids.is_a? Array
          body = { cpcPlanIds: ids }
          response = request( auth, Service ,"getCpcGrpIdByCpcPlanId",  body )
          process( response, 'cpcPlanGrpIds', debug ){ |x| make_planGroupIds( x ) }
        end

        private
        def self.make_planGroupIds( cpcPlanGrpIdTypes )
          cpcPlanGrpIdTypes = [cpcPlanGrpIdTypes] unless cpcPlanGrpIdTypes.is_a? Array
          planGroupIds = []
          cpcPlanGrpIdTypes.each do |cpcPlanGrpIdType|
            planGroupId = { }
            planGroupId[:plan_id] = cpcPlanGrpIdType[:cpc_plan_id]
            planGroupId[:group_ids] = cpcPlanGrpIdType[:cpc_grp_ids]
            planGroupIds << planGroupId
          end
          return planGroupIds
        end

        private
        def self.make_planGroups( cpcPlanGrpTypes )
          # 多加一行change成array
          cpcPlanGrpTypes = [cpcPlanGrpTypes] unless cpcPlanGrpTypes.is_a? Array
          planGroups = []
          cpcPlanGrpTypes.each do |cpcPlanGrpType|
            planGroup = {}
            planGroup[:plan_id] = cpcPlanGrpType[:cpc_plan_id]
            planGroup[:groups] = reverse_type( cpcPlanGrpType[:cpc_grp_types] )
            planGroups << planGroup
          end
          return planGroups
        end

      end # class group
    end # class baidu
  end # API
end # module