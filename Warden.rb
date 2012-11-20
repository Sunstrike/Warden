#!/usr/bin/env ruby -wKU

## Warden
##      => Core
#
# AZI IRC moderation bot
# 
# Copyright (C) 2012 Robert Tully
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

require 'cinch'
require_relative 'config.rb'

VERSION = "v0.0.2"

if UTILITIES_ENABLED
    require_relative 'plugins/Utilities.rb'
    plugins = [Hugsim, Ecu, Bord, NES]
else
    plugins = []
end
if IRC_NICKSERV_IDENTIFY
    require 'cinch/plugins/identify'
    plugins.push(Cinch::Plugins::Identify)
end
if MODERATIOND_ENABLED
    require_relative 'plugins/Moderationd.rb'
    plugins.push(Moderationd)
end
if KICKER_ENABLED
    require_relative 'plugins/Kicker.rb'
    plugins.push(Kicker)
end
if SRV_MANAGER_ENABLED
    require_relative 'plugins/SrvManager.rb'
    plugins.push(SrvManager)
end

puts "STARTING CINCH CORE:"
puts "\tServer: #{IRC_SERVER}"
puts "\tChannel: ##{CHANNEL_NAME}"
puts "\tBot Account: #{IRC_ACCOUNT}"
puts "\tBot nick: #{IRC_NICK}"

bot = Cinch::Bot.new do
    configure do |c|
        c.server = IRC_SERVER
        c.nick = IRC_NICK
        c.user = IRC_ACCOUNT
        c.realname = "Warden::Cinch (#{VERSION}) by Sunstrike"
        c.channels = ["##{CHANNEL_NAME}"]
        c.plugins.plugins = plugins
        c.messages_per_second = 5
        if IRC_NICKSERV_IDENTIFY
            c.plugins.options[Cinch::Plugins::Identify] = {
                :username => IRC_NICKSERV_USERNAME,
                :password => IRC_NICKSERV_PASSWORD,
                :type     => :nickserv,
            }
        end
        if SRV_MANAGER_ENABLED
            c.plugins.options[SrvManager] = {
                :wrapper => SRV_MANAGER_WRAPPER,
                :socket  => SRV_MANAGER_SOCKET,
            }
        end
    end
end

if !DEBUG_MODE
    bot.start
end