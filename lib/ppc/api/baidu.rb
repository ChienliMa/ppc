# -*- coding:utf-8 -*-
require 'ppc/api/baidu/account'
require 'ppc/api/baidu/plan'
require 'ppc/api/baidu/bulk'
require 'ppc/api/baidu/group'
require 'ppc/api/baidu/keyword'
require 'ppc/api/baidu/report'
require 'ppc/api/baidu/creative'
require 'awesome_print'
require 'net/http'
require 'net/https'
require 'json'
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

      def self.request( auth, service, method, params = {} )
        '''
        request should return whole http response including header
        '''
        uri = URI("https://api.baidu.com/json/sms/v3/#{service}Service/#{method}")
        http_body = {
          header: {
            username:   auth[:username],
            password:   auth[:password],
            token:      auth[:token]
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
        result = {}
        result[:succ] = response['header']['desc']=='success'? true : false
        result[:failure] = response['header']['failures']
        result[:result] = func[ response['body'][key] ]
        return result
      end # process

      def self.make_type( params, map = @map)
        '''
        tranfesr ppc api to search engine api
        @ input
          params : list of hash complying with PPC gem api  
          map : list of pairs(lists) of symbol complying with following api
          map = [ 
                        [ ppc_key, api_key ],
                        [ ppc_key, api_key ],
                        [ ppc_key, api_key ],
                                        ...
                        ]
          Ex: 
          baidu_group_map = [ [ :id, :adgroupId],
                                                  [ :price, :maxPrice],
                                                          ...                 ]
        ===================
        @ output:
          types : list of hash that complying with search engine api
        '''
        params = [ params ] unless params.is_a? Array

        types = []
        params.each do |param|
          type = {}

          map.each do |key|
            value = param[ key[0] ]
            type[ key[1] ] = value if value != nil
          end

          types << type
        end
        return types
      end

      def self.reverse_type( types, map = @map )
        '''
        transfer search engine api to ppc api
        @ input
          types : list of hash that complying with search engine api
          map : list of pairs(lists) of symbol, for more details please 
                      read docs of make_type()
        ===================
        @ output:
          params : list of hash complying with PPC gem api  
        '''
        types = [ types ] unless types.is_a? Array

        params = []
        types.each do |type|
          param = {}
          
          map.each do |key|
              value = type[ key[1].to_s ]
              param[ key[0] ] = value if value != nil
          end

          params << param
        end
        return params
      end

      end # Baidu
  end # API
end # PPC
