module PPC
  module Operation
    module Report

      def query_report( param = nil, debug = false )
        call('report').query_report( @auth, param, debug )
      end

      def creative_report( param = nil, debug = false )
        call('report').creative_report( @auth, param, debug )
      end

      def keyword_report( param = nil, debug = false )
        call('report').keyword_report( @auth, param, debug )
      end

    end
  end
end
