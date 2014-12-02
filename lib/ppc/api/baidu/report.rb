# -*- coding:utf-8 -*-
module PPC
  module API
    class Baidu
      class Report< Baidu
        Service = 'Report'
      
        # 需要用到的映射集合
        Type_map = { 'account' => 2, 'plan'=> 10, 'group'=> 11, 
                      'keyword'=> 14, 'creative'=> 12, 'pair'=> 15, 
                       'region'=> 3, 'wordid'=> 9 }
        Level_map = {  'account' => 2, 'plan' => 3, 'group' => 5, 
                        'creative' => 7, 'keywordid' => 11, 'pair' => 12, 
                         'wordid' => 6 }
        Device_map = { 'all' => 0, 'pc' => 1, 'mobile' => 2 }
        Unit_map = { 'day' => 5, 'week' => 4, 'month' => 3, 'year' => 1, 'hour' => 7 }


        # 少用，而且百度说明文档不清楚，实际操作不可行，失效
        # def self.get_realtime( auth, params, type = 'data'  )
        #   request = make_realtimerequest( params )[0]
        #   body = { realTimeRequestTypes:  request }
        #   response = request( auth, Service, 'getRealTimeData' ,body)
        #   if debug
        #     return response
        #   end
        #   response = case type
        #     when 'data'     then    response['body']['realTimeResultTypes']
        #     when 'query'  then   response['body']['realTimeQueryResultTypes']
        #     when 'pair'      then    response['body']['realTimePairResultTypes']
        #   end
        #   return response                   
        # end


        def self.get_id( auth, params  )
          request = make_reportrequest( params )[0]
          body =  { reportRequestType:  request }
          response = request( auth, Service, 'getProfessionalReportId' ,body) 
          process( response, 'reportId' ){ |x| x }
        end

        def self.get_status( auth, id )
          '''
          input id should be string
          '''
          status = {1=>'Waiting' ,2=>'Opearting' ,3=>'Finished'}
          body = { reportId:  id }
          response = request( auth, Service, 'getReportState' ,body)
          process( response, 'isGenerated' ){ |x| status[x] }
        end

        def self.get_url( auth, id  )
          body = { reportId:  id }
          response = request( auth, Service, 'getReportFileUrl' ,body)
          process( response, 'reportFilePath' ){ |x| x }       
        end

        private
        def self.get_date( params )
         begin
            startDate = DateTime.parse(params[:start]).iso8601
            endDate = DateTime.parse(params[:end]).iso8601
          rescue Exception => e
            startDate = (Time.now - 2*24*3600).utc.iso8601
            endDate = (Time.now - 24*3600).utc.iso8601
          end
          return startDate,endDate
        end

        private 
        def self.make_realtimerequest( params )
          '''
          make RealTimeRequestType
          没有封装关键字：attribute，order,statIds
          '''
          params = [ params ] unless params.is_a? Array
          requesttypes = []
          params.each do  |param|
            requesttype = {}
            startDate, endDate = get_date( param )

            requesttype[:performanceData]   =     param[:fields]   ||   %w(click impression)
            requesttype[:reportType]        =     Type_map[ param[:type] ]      if  param[:type] 
            requesttype[:levelOfDetails]    =     Level_map[  param[:level] ]   if param[:level]
            requesttype[:statRange]         =     Level_map[ param[:range] ]    if param[:range]
            requesttype[:unitOfTime]        =     Unit_map[ param[:unit] ]      if param[:unit] 
            requesttype[:number]            =     param[:number]                if  param[:number]
            requesttype[:device]            =     Device_map[ param[:device] ]  if param[:device]
            requesttype[:startDate]         =     startDate
            requesttype[:endDate]           =     endDate
            requesttypes << requesttype
          end
          return requesttypes
        end

        private
        def self.make_reportrequest( params )
          '''
          make RepoerRequestType
          '''
          params = [ params ] unless params.is_a? Array
          requesttypes = []
          params.each do  |param|
            requesttype = {}
            startDate, endDate = get_date( param )

            requesttype[:performanceData]   =     param[:fields]  ||  %w(click impression)
            requesttype[:reportType]        =     Type_map[ param[:type] ]     if  param[:type]
            requesttype[:levelOfDetails]    =     Level_map[  param[:level] ]  if param[:level]
            requesttype[:statRange]         =     Level_map[ param[:range] ]   if param[:range]
            requesttype[:unitOfTime]        =     Unit_map[ param[:unit] ]     if param[:unit]
            requesttype[:device]            =    Device_map[ param[:device] ]  if param[:device]
            requesttype[:idOnly]            =    param[:id_only]  ||  false
            requesttype[:startDate]         =    startDate
            requesttype[:endDate]           =    endDate
            requesttypes << requesttype
          end
          return requesttypes
        end

      end # Repost
    end # Baidu
  end # API
end # PPC
