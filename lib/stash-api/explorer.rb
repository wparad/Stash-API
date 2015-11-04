require 'open-uri'
require 'rest-client'

module Stash
  class Explorer
    attr_accessor :server

    def initialize(username, password, server)
      raise 'API username must be specified' if !username
      raise 'API password must be specified' if !password
      raise 'Stash server must be specified' if !server
      @username = username
      @password = password
      @server = server

      @get_repos_url = File.join("https://#{@server}", 'rest', 'api', '1.0', 'projects')
    end

    def get_repositories(project_key)
      repos = []
      RestClient::Request.new(
        :method => :get,
        :url => URI::encode("#{File.join(@get_repos_url, project_key, 'repos')}?limit=1000"),
        :user => @username,
        :password => @password,
        :headers => { :accept => :json, :content_type => :json }).execute do |response, request, result|
          raise "Could not get repositories - #{JSON::pretty_generate(JSON::parse(response.body))}" if !response.code.to_s.match(/^2\d{2}$/)
          JSON::parse(response)['values'].each{ |h| repos << h['slug'] }
      end
      repos
    end
    
    def get_file(project_key, repo, path)
      RestClient::Request.new(
        :method => :get,
        :url => URI::encode("#{File.join(@get_repos_url, project_key, 'repos', repo, 'browse', path)}?limit=1000"),
        :user => @username,
        :password => @password,
        :headers => { :accept => :json, :content_type => :json }).execute do |response, request, result|
          return response.code.to_s.match(/^2\d{2}$/) ?  JSON::parse(response)['lines'].map{|t| t['text']}.join("\n") : nil
      end
    end
  end
end