#!/usr/bin/env ruby -wKU

## Warden
##      => Raven helper module
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

class RavenHelper
    include Cinch::Plugin
    class << self
        attr_reader :commands
    end

    @commands = []
    @logger = nil

    listen_to(:connect, {:method => :setup})

    def setup(msg)
        info "Initialising Raven logger..."
        if @logger == nil
            @logger = RavenLogger.new(nil, bot)
        end
        if !bot.loggers.include? @logger
            bot.loggers.push @logger
        end
    end
end

class RavenLogger < Cinch::Logger
    def initialize(out, bot)
        @bot = bot
    end

    def exception(e)
        Raven.capture_exception(e, {
            :logger => 'RavenLogger',
            :extra => {
                "bot.nick" => @bot.nick,
                "bot.channels" => @bot.channels.inspect,
                "bot.plugins" => @bot.plugins.inspect,
                "bot.config" => @bot.config.inspect
            }
        })
    end

    def log(messages, event = :debug, level = event)
        Raven.capture_message(messages, {
            :logger => 'RavenLogger',
            :extra => {
                "event" => event.to_s,
                "level" => level.to_s,
                "bot.nick" => @bot.nick,
                "bot.channels" => @bot.channels.inspect,
                "bot.plugins" => @bot.plugins.inspect,
                "bot.config" => @bot.config.inspect
            }
        })
    end

    def debug(message)
        return
    end

    def error(message)
        log(message, :error)
    end

    def fatal(message)
        log(message, :fatal)
    end

    def info(message)
        return
    end

    def warn(message)
        return
    end

    def incoming(message)
        return
    end

    def outgoing(message)
        return
    end

    def will_log?(level)
        LevelOrder.index(level) >= LevelOrder.index(@level)
    end
end