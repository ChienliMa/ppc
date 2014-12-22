# -*- coding:utf-8 -*-
module PPC
  module API
    class Shenma
      class Report< Shenma
        Service = 'Report'
      
        # 需要用到的映射集合
        Type_map = { 'account' =>2, 'plan'=> 10, 'group'=> 11, 
                      'keyword'=> 14, 'creative'=> 12, 'region'=> 3, 
                       'query'=> 6, 'phone' => 22, 'app' => 23 }

        Level_map = {  'account' => 2, 'plan' => 3, 'group' => 5, 
                        'creative' => 7, 'keyword' => 11, 'phone' => 22,
                         'app' => 23, 'pair' => 12 }

        Unit_map = { 'day' => 5, 'month' => 3, 'default' => 8 }

        def self.get_id( auth, params, debug = false )
          request = make_reportrequest( params )
          body =  { ReportRequestType: request }
          response = request( auth, '/report/getReport' ,body) 
          process( response, 'reportId', debug ){ |x| x }
        end

        def self.get_state( auth, id, debug = false)
          '''
          input id should be string
          '''
          status = {1=>'Waiting' ,2=>'Opearting' ,3=>'Finished'}
          body = { taskId:  id }
          response = request( auth, '/task/getTaskState' ,body)
          process( response, 'isGenerated', debug ){ |x| status[x] }
        end

        # todo : rewrite method
        def self.download( auth, id, debug = false )
          body = { fileId:  id }
          response = request( auth, '/file/download' ,body)
          process( response, 'reportPath', debug ){ |x| x }       
        end

        private
        def self.make_reportrequest( param )
          '''
          make RepoerRequestType
          ======================
          For more docs please have a look at
          ::PPC::API::Baidu::Report:make_reportrequest()
          '''
          requesttype = {}
          requesttype[:performanceData]    =     param[:fields] 
          requesttype[:reportType]         =     Type_map[ param[:type] ]        if  param[:type] 
          requesttype[:levelOfDetails]     =     Level_map[  param[:level] ]     if param[:level]
          requesttype[:statRange]          =     Level_map[ param[:range] ]      if param[:range]
          requesttype[:unitOfTime]         =     Unit_map[ param[:unit] ]        if param[:unit]
          requesttype[:idOnly]             =     param[:id_only]   || false
          requesttype[:statIds]            =     param[:ids] if param[:ids] != nil
          requesttype[:startDate] = parse_date( param[:startDate] )
          requesttype[:endDate]   = parse_date( param[:endDate] )
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
          date.to_s[0,10]
        end

        def download_report( auth, param, debug = false )
          response = call('report').get_id( auth, param )
          if response[:succ]
            id = response[:result]
            p "Got report id:" + id.to_s if debug 
            loop do
              sleep 2 
              break if call('report').get_state( auth, id )[:result] == 'Finished'
              p "Report is not generated, waiting..." if debug 
            end
            # need to rewrite the download method here.
            url = call('report').get_url( auth, id )[:result]
            return open(url).read.force_encoding('gb18030').encode('utf-8')
          else
            raise response[:failure][0]["message"]
          end
        end

        ###########################
        # intreface for Operation #
        ###########################
        def query_report( auth, param = nil, debug = false )
          param = {} if not param
          param[:type]   ||= 'query'
          param[:fields] ||=  %w(click)
          param[:level]  ||= 'pair'
          param[:range]  ||= 'account'
          param[:unit]   ||= 'day'
          download_report( param, debug )
        end

        def creative_report( auth, param = nil, debug = false )
          param = {} if not param
          param[:type]   ||= 'creative'
          param[:fields] ||=  %w( cost cpc click impression ctr )
          param[:level]  ||= 'creative'
          param[:range]  ||= 'creative'
          param[:unit]   ||= 'day'
          download_report( param, debug )
        end

        def keyword_report( auth, param = nil, debug = false )
          param = {} if not param
          param[:type]   ||= 'keyword'
          param[:fields] ||=  %w( cost cpc click impression ctr )
          param[:level]  ||= 'keywordid'
          param[:range]  ||= 'keywordid'
          param[:unit]   ||= 'day'
          download_report( param, debug )
        end

      end # Repost
    end # Baidu
  end # API
end # PPC
