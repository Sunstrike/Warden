#!/usr/bin/env ruby -wKU

## Warden
##      => Kicker module
#
# AZI IRC moderation bot
#
# Copyright (C) 2012 Sunstrike <sunstrike@azurenode.net>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#

require 'sinatra/base'
require 'ipaddr'
require 'multi_json'

# Currently only supports GitHub
class POSTNotify
    include Cinch::Plugin

    class << self
        attr_reader :commands
    end

    @commands = []

    def initialize(bot)
        super bot

        t = Thread.new(self) { |callback|
            SinatraServer.set :controller, callback
            SinatraServer.set :port, config[:port]
            SinatraServer.run!
        }
    end

    ## ----------------------------------------------------------
    ## GITHUB
    def githubEventSend(data)
        begin
            channel = Channel(config[:channel])
            repo = data['repository']['name']
            branch = (/.+\/(.+)/.match(data['ref']))[1]
            commits = data['commits']

            channel.send "#{repo}@#{branch}: #{data['commits'].length} changes pushed to GitHub."
            commits.each { |c|
                shortHash = c['id'][1..7]
                channel.send "[#{shortHash}] #{c['message']} (#{c['author']['username']})"
            }
        rescue Exception => e
            warn "Failed to send commit messages: #{e.message}"
        end
    end

    def handleGithub(req, payload)
        ret = 200
        begin
            if verifyOriginGitHub(req.ip)
                data = MultiJson.decode payload
                info "Got POST from Github endpoint: #{data.inspect}"
                githubEventSend(data)
            else
                ret = 403
            end
        #rescue Exception => e
        #    warn "Error in Github endpoint (#{e.message})"
        #    ret = 500
        end
        ret
    end

    def verifyOriginGitHub(ipAddr)
        ip = IPAddr.new(ipAddr)
        config[:gh_ips].each { |zone|
            zoneIp = IPAddr.new(zone)
            if zoneIp.include? ip
                return true
            end
        }
        false
    end

    ## ----------------------------------------------------------
    ## GITLAB
    def gitlabEventSend(data)
        begin
            channel = Channel(config[:channel])
            repo = data['repository']['name']
            branch = (/.+\/(.+)/.match(data['ref']))[1]
            pusher = data['user_name']
            commits = data['commits']

            channel.send "#{repo}@#{branch}: #{pusher} has pushed #{data['total_commits_count']} changesets to GitLab."
            commits.each { |c|
                shortHash = c['id'][1..7]
                channel.send "[#{shortHash}] #{c['message']} (#{c['author']['name']})"
            }
        rescue Exception => e
            warn "Failed to send commit messages: #{e.message}"
        end
    end

    def handleGitlab(req)
        ret = 200
        begin
            if verifyOriginGitlab(req.ip)
                req.body.rewind
                data = MultiJson.decode req.body.read
                info "Got POST from Gitlab endpoint: #{data.inspect}"
                gitlabEventSend(data)
            else
                ret = 403
            end
        rescue Exception => e
            warn "Error in Gitlab endpoint (#{e.message})"
            ret = 500
        end
        ret
    end

    def verifyOriginGitlab(ipAddr)
        ip = IPAddr.new(ipAddr)
        config[:gl_ips].each { |zone|
            zoneIp = IPAddr.new(zone)
            if zoneIp.include? ip
                return true
            end
        }
        false
    end

end

class SinatraServer < Sinatra::Base
    set :port, 9090
    set :environment, :production
    server.delete 'webrick' # Max URI size is too low for Github payloads with WEBrick

    post '/github' do
        settings.controller.handleGithub(request, params[:payload])
    end

    post '/gitlab' do
        settings.controller.handleGitlab(request)
    end
end
