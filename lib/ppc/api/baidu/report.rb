# -*- coding:utf-8 -*-
module PPC
  module API
    class Baidu
      class Report< Baidu
        Service = 'Report'
      
        # 需要用到的映射集合
        Type_map = { 'account' => 2, 'plan'=> 10, 'group'=> 11, 
                      'keyword'=> 14, 'creative'=> 12, 'pair'=> 15, 
                       'region'=> 3, 'wordid'=> 9 , 'query'=>6 }

        Level_map = {  'account' => 2, 'plan' => 3, 'group' => 5, 
                        'creative'=> 7, 'keywordid' => 11, 'pair' => 12, 
                         'wordid' => 6 }

        Device_map = { 'all' => 0, 'pc' => 1, 'mobile' => 2 }

        Unit_map = { 'day' => 5, 'week' => 4, 'month' => 3, 'year' => 1, 'hour' => 7 }

        ########################
        # API wraping function #
        ########################
        def self.get_id( auth, params  )
          request = make_reportrequest( params )
          body =  { reportRequestType:  request }
          response = request( auth, Service, 'getProfessionalReportId' ,body) 
          process( response, 'reportId' ){ |x| x }
        end

        def self.get_state( auth, id )
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
        def self.make_reportrequest( param )
          """
          make RepoerRequestType
          ==============
          @Input : :fields,:type,:level,:range,:unit,:device,:id_only,:startDate:endDate
          ==============
          Note:
            We cast [ type, level, range, unit,device ] from int to string.
          For more information please see those map at the begining of the file
          """
          requesttype = {}
          requesttype[:performanceData]   =     param[:fields]  || %w(click impression)
          requesttype[:reportType]        =     Type_map[ param[:type] ]      if  param[:type]
          requesttype[:levelOfDetails]    =     Level_map[  param[:level] ]   if param[:level]
          requesttype[:statRange]         =     Level_map[ param[:range] ]    if param[:range]
          requesttype[:unitOfTime]        =     Unit_map[ param[:unit] ]      if param[:unit]
          requesttype[:device]            =     Device_map[ param[:device] ]  if param[:device]
          requesttype[:idOnly]            =     param[:id_only] || false
          requesttype[:startDate]         =     parse_date( param[:startDate] )
          requesttype[:endDate]           =     parse_date( param[:endDate] )
          return requesttype
        end

        private 
        def self.parse_date( date )
          """
          Cast string to time:
          'YYYYMMDD' => Time
          """
          if date
            y = date[0..3]
            m = date[4..5]
            d = date[6..7]
            date = Time.new( y, m, d )
          else
            date = (Time.now - 24*3600)
          end
          date
        end

        #################################
        # useful function for operation #
        #################################
        def self.query_report( auth, param = nil, debug = false )
          param = {} if not param
          param[:type]   ||= 'query'
          param[:fields] ||=  %w(click impression)
          param[:level]  ||= 'pair'
          param[:range]  ||= 'account'
          param[:unit]   ||= 'day'
          download_report( auth, param, debug )
        end

        def self.creative_report( auth, param = nil, debug = false )
          param = {} if not param
          param[:type]   ||= 'creative'
          param[:fields] ||=  %w(impression click cpc cost ctr cpm position conversion)
          param[:level]  ||= 'creative'
          param[:range]  ||= 'creative'
          param[:unit]   ||= 'day'
          download_report( auth, param, debug )
        end

        def self.keyword_report( auth, param = nil, debug = false )
          param = {} if not param
          param[:type]   ||= 'keyword'
          param[:fields] ||=  %w(impression click cpc cost ctr cpm position conversion)
          param[:level]  ||= 'keywordid'
          param[:range]  ||= 'keywordid'
          param[:unit]   ||= 'day'
          download_report( auth, param, debug )
        end
   
        def self.download_report( auth, param, debug = false )
          response = get_id( auth, param )
          if response[:succ]
            id = response[:result]
            p "Got report id:" + id.to_s if debug 
            loop do
              sleep 2 
              break if get_state( auth, id )[:result] == 'Finished'
              p "Report is not generated, waiting..." if debug 
            end
            url = get_url( auth, id )[:result]
            return open(url).read.force_encoding('gb18030').encode('utf-8')
          else
            raise response[:failure][0]["message"]
          end
        end

      end # Repost
    end # Baidu
  end # API
end # PPC
