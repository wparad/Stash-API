# Stash-API
Ruby Stash API library.

[![Gem Version](https://badge.fury.io/rb/stash-api.svg)](http://badge.fury.io/rb/stash-api)

[![Build Status](https://travis-ci.org/wparad/Stash-API.svg?branch=master)](https://travis-ci.org/wparad/Stash-API)

### Usage

	#!/usr/bin/ruby

	require 'json'
	require 'stash-api'

	stash_client = Stash::Client.new('username', 'password')

	#Setup hook configurations for the repository
	hooks = {
	  'com.zerosumtech.wparad.stash.stash-http-request-trigger:postReceiveHook' => {
		:config => {
		  "url"=>"https://jenkins/job/JenkinsJobName.Merge/buildWithParameters?cause=Stash&token=TOKEN",
		  "refRegex"=>"^refs/heads/release/.*$",
		  "prurl"=>"https://jenkins/job/JenkinsJobName.PR/buildWithParameters?cause=Stash&token=TOKEN",
		}
	  },
	  'com.atlassian.stash.plugin.stash-protect-unmerged-branch-hook:protect-unmerged-branch-hook' => {}
	  }
	}

	stash_client.set_hooks(hooks)
	puts JSON::pretty_generate(stash_client.get_hooks())

	#Set branching permissions
	permissions = [
	  {
		'type' => 'fast-forward-only',
		'matcher' => {
		  'id' => 'development',
		  'type' => {
			'id' => 'MODEL_BRANCH'
		  }
		}
	  },
	  {
		'type' => 'no-deletes',
		'matcher' => {
		  'id' => 'development',
		  'type' => {
			'id' => 'MODEL_BRANCH'
		  }
		}
	  }
	]
	stash_client.set_branch_permissions(permissions)
	puts JSON::pretty_generate(stash_client.get_branch_permissions())

	#Set up automatic merging
	stash_client.set_automatic_merging()
	puts stash_client.get_automatic_merging()

	#Set up pull request merge settings
	puts stash_client.get_pull_request_settings()
	stash_client.set_pull_request_settings({:builds => 1, :approvers => 1})
