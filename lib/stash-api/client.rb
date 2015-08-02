require 'open-uri'
require 'rest-client'

module Stash
  class Client
    attr_accessor :server, :project, :repository_name

    def initialize(username, password, config = {:follow_fork => true, :url => nil, :verify_ssl => true})
      raise 'API username must be specified' if !username
      raise 'API password must be specified' if !password
      @username = username
      @password = password

      remote_origin_url = config[:url] || %x[git config --get remote.origin.url]
      raise "Repository URL is not set and cannot be inferred from the git config." if !remote_origin_url

      match = remote_origin_url.match(/(ssh|https?):\/\/([^@]*@)?(?<server>[^\:\/]*)[^\/]*\/(scm\/)?(?<project>[^\/].*)\/(?<repository_name>[^\/]*)\.git$/)
      raise "Remote origin cannot be inferred from the url: #{remote_origin_url}.  Run `git remote add origin URL` to add an origin." if !match
      @server = match[:server]
      @project = match[:project]
      @repository_name = match[:repository_name]

      @remote_api_url = File.join("https://#{@server}", 'rest', 'api', '1.0', 'projects', @project, 'repos', @repository_name)
      @branch_permissions_url = File.join("https://#{@server}", 'rest', 'branch-permissions', '2.0', 'projects', @project, 'repos', @repository_name, 'restrictions')
      json = RestClient::Resource.new(@remote_api_url, {:user => @username, :password => @password, :verify_ssl => config[:verify_ssl]}).get
      repository_information = JSON::pretty_generate(JSON.parse(json))
      
      #If the repository is a fork, use it's forked source to get this information
      if repository_information['origin'] && config[:follow_fork]
        @project = repository_information['origin']['project']['key']
        @repository_name = repository_information['origin']['slug']
      end
    end
    
    SETTINGS_HOOKS_URL = File.join('settings', 'hooks')
    def setup_repository(config = {})
      #Set branch permissions (this should just be a list)
        #group on edits/no changing history
        #service user on tags
      #Set Hooks should be a list that allows an hash to be inspected
      #Pull request settings
      #Set branching strategy
    end
    
    def set_hooks(hooks)
      hooks.keys.each do |hook|
        RestClient::Request.new(
          :method => :put,
          :url => URI::encode("#{File.join(@remote_api_url, SETTINGS_HOOKS_URL)}/#{hook}/enabled"),
          :user => @username,
          :password => @password,
          :headers => { :accept => :json, :content_type => :json }).execute do |response, request, result|
            raise "Could not enable hook: #{hook} - #{JSON::pretty_generate(JSON::parse(response.body))}" if !response.code.to_s.match(/^2\d{2}$/)
        end

        config = hooks[hook][:config]
        if config
          RestClient::Request.new(
            :method => :put,
            :url => URI::encode("#{File.join(@remote_api_url, SETTINGS_HOOKS_URL)}/#{hook}/settings"),
            :user => @username,
            :password => @password,
            :payload => config.to_json,
            :headers => { :accept => :json, :content_type => :json }).execute do |response, request, result|
              raise "Could not configure hook: #{hook} - #{JSON::pretty_generate(JSON::parse(response.body))}" if !response.code.to_s.match(/^2\d{2}$/)
          end
        end
      end
    end

    def get_hooks()
      config = {}
      RestClient::Request.new(
        :method => :get,
        :url => URI::encode("#{File.join(@remote_api_url, SETTINGS_HOOKS_URL)}?limit=1000"),
        :user => @username,
        :password => @password,
        :headers => { :accept => :json, :content_type => :json }).execute do |response, request, result|
          raise "Could not get hooks - #{JSON::pretty_generate(JSON::parse(response.body))}" if !response.code.to_s.match(/^2\d{2}$/)
          JSON::parse(response)['values'].map do |h|
            hook = h['details']['key']
            config[hook] = {:config => nil, :enabled => h['enabled']}
            
            RestClient::Request.new(
              :method => :get,
              :url => URI::encode(File.join(@remote_api_url, SETTINGS_HOOKS_URL, hook, 'settings')),
              :user => @username,
              :password => @password,
              :headers => { :accept => :json, :content_type => :json }).execute do |response, request, result|
                config[hook][:config] = JSON::parse(response != '' ? response : '{}') if response.code.to_s.match(/^2\d{2}$/)
            end
          end
      end
      config
    end
    
    def get_branch_permissions()
      @branch_permissions_url
      RestClient::Request.new(
        :method => :get,
        :url => URI::encode(@branch_permissions_url),
        :user => @username,
        :password => @password,
        :headers => { :accept => :json, :content_type => :json }).execute do |response, request, result|
          raise "Could not get branch permissions - #{JSON::pretty_generate(JSON::parse(response.body))}" if !response.code.to_s.match(/^2\d{2}$/)
      end
    end
    
    def get_pull_request_settings()
    end
    
    def get_branching_strategy()
    end

  end
end
