# -*- coding:utf-8 -*-
require 'json'
module PPC
  module API
    class Qihu
      class Account < Qihu
        Service = 'account'

        @map = [
                [ :id, :uid ],
                [ :name, :userName ],
                [ :email, :email],
                [ :company, :companyName],
                [ :industry1, :industry1],
                [ :industry2, :industry2],
                [ :balance, :balance],
                [ :budget, :budget],
                [ :resources, :resources],
                [ :open_domains, :allowDomain]
              ]
        
        def self.info( auth )
          response = request( auth, Service, 'getInfo' )
          process( response, '' ){ |x| reverse_type( x )[0]}
        end

        def self.update( auth, params )
          '''
          对奇虎两个update的在封装。如果所有操作成功，succ为true，否则为false
          failure中以字符串方式返回失败的操作
          '''
          result = {}
          result[:succ] = true
          result[:failure] = []
          result[:result] = []

          if params[:budget] != nil
            budget_result = update_budget( auth, params[:budget] )
            result[:succ] = result[:succ] && budget_result[:succ]
            result[:failure] << 'budget' unless budget_result[:succ]
          end

          if params[:exclude_ip] != nil
            ip_result = update_exclude_ip( auth, params[:exclude_ip] )
            result[:succ] = result[:succ] && ip_result[:succ]
            result[:failure] << 'exclude_ip' unless budget_result[:succ]
          end

          return result
        end

        def self.get_all_object( auth, ids )
          #文档上面写的输入类型是String？
          body = { 'idList' =>  ids }
          response = request( auth, Service, 'getAllObjects' )
          process( response, 'account_getAllObjects_response' ){ |x| x }
        end

        def self.get_file_state( auth, id )
          body = { 'fileId' => id }
          response = request( auth, Service, 'getAllObjects' , body )
          process( response, 'account_getFileState_response' ){ |x| x }
        end

        def self.get_exclude_ip( auth )
          response = request( auth, Service, 'getExcludeIp' )
          process( response, 'excludeIpList' ){ |x| x['item'] }
        end

        private
        def self.update_budget( auth, budget )
          response = request( auth, Service, 'updateBudget', { budget:budget })
          process( response, 'affectedRecords' ){ | x | x.to_i==1?'success':'failure' }
        end

        private
        def self.update_exclude_ip( auth, ips )
          ips = to_json_string( ips )
          response = request( auth, Service, 'updateExcludeIp', { excludeIpList: ips } )
          process( response, 'excludeIpList' ){ | x | x }
        end

      end
    end
  end
end