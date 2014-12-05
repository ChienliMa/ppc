module PPC
  module Operation
    module Report

      def query_report( param = nil )
        if not param
          param = {}
          param[:type]   = 'pair'
          param[:fields] =  %w(click impression)
          param[:level]  = 'pair'
          param[:range]  = 'account'
          param[:unit]   = 'day'
        end
        download_report( param )
      end

      def creative_report( param = nil )
        if not param
          param = {}
          param[:type]   = 'creative'
          param[:fields] =  %w(impression click cpc cost ctr cpm position conversion)
          param[:level]  = 'creative'
          param[:range]  = 'creative'
          param[:unit]   = 'day'
        end
        download_report( param )
      end

      def keyword_report( param = nil )
        if not param
          param = {}
          param[:type]   = 'keyword'
          param[:fields] =  %w(impression click cpc cost ctr cpm position conversion)
          param[:level]  = 'keywordid'
          param[:range]  = 'keywordid'
          param[:unit]   = 'day'
        end
        download_report( param )
      end
 
      def download_report( param )
        id = call('report').get_id( @auth, param )[:result]
        p "get report id:" + id.to_s

        loop do
          sleep 3 
          break if call('report').get_state( @auth, id )[:result] == 'Finished'
          p "Report is not generated, waiting..."
        end

        url = call('report').get_url( @auth, id )[:result]
        return open(url).read.force_encoding('gb18030').encode('utf-8')
      end

    end
  end
end
