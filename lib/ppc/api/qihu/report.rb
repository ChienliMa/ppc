# -*- coding:utf-8 -*-
require 'json'

module PPC
  module API
    class Qihu
      class Report< Qihu
        Service = 'report'

        @map =[
                [:queryword,:queryword],
                [:plan_id,:campaignId],
                [:creative_id,:creativeId],
                [:keyword,:keyword],
                [:views,:views],
                [:clicks,:clicks],
                [:startDate,:startDate],
                [:endDate,:endDate],
                [:date,:date],
                [:keyword_id,:keywordId],
                [:group_id,:groupId],
                [:cost,:totalCost],
                [:position,:avgPosition],
                [:total_num,:totalNumber],
                [:total_page,:totalPage]
              ]

        ###################
        # API abstraction #
        ###################
        def self.abstract( auth, type_name, method_name, key, param = nil, &func )
          body = make_type( param )
          response = request( auth, Service, method_name, body )
          process( response, key ){ |x| func[ x ] }
        end

        type_list = ['keyword', 'query', 'creative', 'sublink']
        type_list.each do |type|
          # type
          define_singleton_method type.to_sym do |auth, param|
              abstract( auth, type, type, type+'List', param ){ |x| x['item']}
          end
          # typeCount
          define_singleton_method (type+'_count').to_sym do |auth, param|
              response = abstract( auth, type, type+'Count', '', param ){ |x| get_item(x) }
              response[:result] = response[:result][0]
              return response
          end
          # typeNow
          define_singleton_method (type+'_now').to_sym do |auth, param|
              abstract( auth, type, type+'Now', type+'List', param ){ |x| x['item']}
          end
          # typeNowCount
          define_singleton_method (type+'_now_count').to_sym do |auth, param|
              response = abstract( auth, type, type+'NowCount', '', param ){ |x| get_item(x) }
              response[:result] = response[:result][0]
              return response
          end
        end

        ############################
        # Interfaces for operation #
        ############################
        def self.keyword_report( auth, param, debug = false )
          download_report(auth, 'keyword', param, debug )
        end

        def self.creative_report( auth, param, debug = false )
          download_report(auth, 'creative', param, debug)
        end
        
        def self.download_report(auth, type, param, debug = false)
          # deal_with time
          now = Time.now.to_s[0...10]
          is_now = now==parse_date(param[:startDate])
        
          # get page num
          if is_now
            method = (type+'_now_count').to_sym
            count = send(method, auth, param)[:result]
            method = (type+'_now').to_sym
          else
            method = (type+'_count').to_sym
            count = send(method, auth, param)[:result]
            method = type.to_sym
          end
          
          report = []
          count[:total_page].to_i.times do | page_i|
            p "Start downloading #{page_i+1}th page, totally #{count[:total_page]} pages"
            param[:page] = page_i +1
            report_i = send(method, auth, param)[:result]
            report += report_i
          end
        
          return report
        end

        ###################
        # Helper Function #
        ###################
        # incase idlist == nil
        private
        def self.get_item( params )
          return nil if params == nil
          return reverse_type( params ) 
        end

        private 
        def self.make_type( param )
          type = {}
          # add option
          type[:level] = param[:level] || 'account'
          type[:page] = param[:page] || 1
          # add ids
          if param[:ids] != nil
            ids = param[:ids] 
            ids = [ ids ] unless ids.is_a? Array
            type[:IdList] = ids.to_json
          end
          # add date
          if param[:startDate]==nil || param[:endDate]==nil
            type[:startDate], type[:endDate] = get_date()
          else
            type[:startDate] = parse_date( param[:startDate] )
            type[:endDate] = parse_date( param[:endDate] )
          end

          return type
        end

        private
        def self.get_date()
            endDate = Time.now.to_s[0,10]
            startDate = (Time.now - 24*3600).to_s[0,10]
          return startDate,endDate
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

      end # Report
    end # Qihu
  end # API
end # PPC
