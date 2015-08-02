require 'rest-client'

module Stash
  class Client
    attr_accessor :server, :project, :repository_name

    def initialize(username, password, follow_fork = true, url = nil)
      raise 'API username must be specified' if !username
      raise 'API password must be specified' if !password
      @username = username
      @password = password

      remote_origin_url = url || %x[git config --get remote.origin.url]
      raise "Repository URL is not set and cannot be inferred from the git config." if !remote_origin_url

      match = remote_origin_url.match(/(ssh|https?):\/\/([^@]*@)?(?<server>[^\:\/]*)[^\/]*\/(scm\/)?(?<project>[^\/].*)\/(?<repository_name>[^\/]*)\.git$/)
      raise "Remote origin cannot be inferred from the url: #{remote_origin_url}.  Run `git remote add origin URL` to add an origin." if !match
      @server = match[:server]
      @project = match[:project]
      @repository_name = match[:repository_name]

      remote_api_url = File.join("https://#{@server}", 'rest', 'api', '1.0', 'projects', @project, 'repos', @repository_name)

      json = RestClient::Resource.new(remote_api_url, {:user => @username, :password => @password}).get
      repository_information = JSON::pretty_generate(JSON.parse(json))
      
      #If the repository is a fork, use it's forked source to get this information
      if repository_information['origin'] && follow_fork
        @project = repository_information['origin']['project']['key']
        @repository_name = repository_information['origin']['slug']
      end
    end
    
    def setup_repository(hash = {})
      #Set branch permissions (this should just be a list)
        #group on edits/no changing history
        #service user on tags
      #Set Hooks should be a list that allows an hash to be inspected
      #Pull request settings
      #Set branching strategy
    end
  end
end
