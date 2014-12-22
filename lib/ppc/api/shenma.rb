module PPC
  module API
    class Baidu
      @map = nil
      @@debug = false

      def self.debug_on
        @@debug = true
      end

      def self.debug_off
        @@debug = false
      end

      def self.request( auth, path, params = {} )
        '''
        request should return whole http response including header
        '''
        uri = URI("https://e.sm.cn#{path}")
        http_body = {
          header: {
            username:   auth[:username],
            password:   auth[:password],
            token:      auth[:token],
            target:     auth[:tarvget]
          },
          body: params
        }.to_json

        http_header = {
          'Content-Type' => 'application/json; charset=UTF-8'
        }

        http = Net::HTTP.new(uri.host, 443)
        # 是否显示http通信输出
        http.set_debug_output( $stdout ) if @@debug
        http.use_ssl = true

        response = http.post(uri.path, http_body, http_header)
        response = JSON.parse( response.body )
      end

      def self.process( response, key, &func)
        '''
        Process Http response. If operation successes, return value of given keys.
        You can process the result using function &func, or do nothing by passing 
        block {|x|x}
        =========================== 
        @Output: resultType{ desc: boolean, failure: Array,  result: Array }

        failure is the failures part of response\'s header
        result is the processed response body.
        '''
        p response
        result = {}
        result[:succ] = response['header']['desc']=='success'? true : false
        result[:failure] = response['header']['failures']
        result[:result] = func[ response['body'][key] ]
        return result
      end # process
      
    end
  end
end
