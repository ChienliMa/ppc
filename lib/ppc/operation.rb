module PPC
  module Operation

    attr_accessor :id
    
    def initialize( params )
      @id   = params[:id]
      @se   = params[:se]
      @auth = {
        username: params[:username],
        password: params[:password],
        # 在qihu360的api中，apikey就是auth[:token]
        token:    params[:token]
      }
      # add support for qihu360
      if  @se == 'qihu' && params[:accessToken] == nil 
        raise "you are using qihu service, please enter cipherkey" if params[:cipherkey] == nil
        raise "you are using qihu service, please enter cipheriv" if params[:cipheriv] == nil
        cipher = { key: params[:cipherkey], iv: params[:cipheriv] } 
        @auth[:accessToken] = qihu_refresh_token( @auth, cipher )
      else
        @auth[:accessToken] = params[:accessToken]
      end
    end

    def qihu_refresh_token( auth, cipher )
        cipher_aes = OpenSSL::Cipher::AES.new(128, :CBC)
        cipher_aes.encrypt
        cipher_aes.key = cipher[:key]
        cipher_aes.iv = cipher[:iv]
        encrypted = (cipher_aes.update(Digest::MD5.hexdigest( auth[:password] )) + cipher_aes.final).unpack('H*').join
        url = "https://api.e.360.cn/account/clientLogin"
        response = HTTParty.post(url,
          :body => {
          :username => auth[:username],
          :passwd => encrypted[0,64]
          },
          :headers => {'apiKey' => auth[:token] }
        )
        data = response.parsed_response
        data["account_clientLogin_response"]["accessToken"]
    end

    def call(service)
      eval "::PPC::API::#{@se.capitalize}::#{service.capitalize}"
    end

    def download(params = {})
      bulk = ::PPC::Baidu::Bulk.new({
                                      username: @username,
                                      password: @password,
                                      token:    @token,
                                      debug:    @debug
      })

      params[:extended] = params[:extended] || 2

      begin
        file_id = bulk.file_id_of_all(params)
        puts "file_id: #{file_id}" if @debug

        loop do
          state = bulk.state(file_id)
          raise "invalid file state: #{state}" unless %w(1 2 3 null).include? state
          break if state == '3'
          puts "waiting for #{file_id} to be ready. current state:#{state}" if @debug
          sleep 3
        end
        puts "#{file_id} is ready" if @debug
        return bulk.path(file_id)
      rescue
        raise BulkException.new(file_id,bulk)
      end  

      return false
    end

    # ++++++++ #
    # Lazy Code #
    # ++++++++ #

    # helper fucntion
    def get_obj( ids, service )
        '''
        Return service object. 
        Providing single id, return single object.
        Providing multiple ids, return Array of objects
        '''
        class_obj =  eval "::PPC::Opeartion::#{service.capitalize}"
        param = @auth
        param[:se] = @se
        objs = []

        ids.each do |id|
          param[:id] = id
          objs << class_obj.new( param )
        end

        return objs.length == 1 ? objs[0] : objs 
    end

    # +++++ Plan opeartion funcitons +++++ #
    module Plan_operation
      def get_plan( ids )
        ::PPC::Opeartion::get_obj( ids, 'plan')
      end

      def add_plan( plans )
        call('plan').add(@auth,plans)
      end

      def update_plan( plans )
        call('plan').update(@auth,plans)
      end

      def delete_plan( ids )
        call('plan').delete(@auth,ids)
      end
    end

    # +++++ Group opeartion funcitons +++++ #
    module Group_operation
      def get_group( ids )
        ::PPC::Opeartion::get_obj( ids, 'group')
      end

      def add_group( groups )
        call('group').add(@auth,groups )
      end

      def update_group( groups )
        call('group').update( @auth, groups )
      end

      def delete_group( ids )
        call('group').delete( @auth, ids )
      end
    end

    # +++++ Keyword opeartion funcitons +++++ #
    module Keyword_operation
      def get_keyword( ids )
        ::PPC::Opeartion::get_obj( ids, 'keyword')
      end
      
      def add_keyword( keywords )
        call('keyword').add( @auth, keywords )
      end

      def update_keyword( keywords)
        call('keyword').update( @auth, keywords )
      end

      def delete_keyword( ids )
         call('keyword').delete( @auth, ids )
      end
    end

    # +++++ Creative opeartion funcitons +++++ #
    module Creative_operation
      def get_creative( ids )
        ::PPC::Opeartion::get_obj( ids, 'creative')
      end
      
      def add_creative( creatives )
        call('creative').add( @auth, creatives )
      end

      def update_creative( creatives )
        call('creative').update( @auth, creatives )
      end

      def delete_creative( ids )
        call('creative').delete( @auth, ids )
      end
    end

  end # Opeartion
end # PPC

# requires are moved to the end of the file
# because if we load files before defining the 
# module ::PPC::Operation. Errors of 'uninitialized constance'
# will occur
require 'ppc/operation/report'
require 'ppc/operation/account'
require 'ppc/operation/group'
require 'ppc/operation/plan'
require 'ppc/operation/keyword'
require 'ppc/operation/creative'

