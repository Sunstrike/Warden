#!/usr/bin/env ruby -wKU

## Warden
##      => Help module
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

class Help
    include Cinch::Plugin
    class << self
        attr_reader :commands
    end

    @commands = ["!help","!commands"]
    @helpTxt = ""

    match(/help/i)
    match(/commands/i)

    def initialize(bot)
        super bot
        # Setup modules
        cmds = []
        config[:modules].each { |mod|
            begin
                cmds = cmds.concat(mod.commands)
            rescue
                warn "Module " + mod.name + " did not have a commands field!"
            end
        }
        debug "HelpLoader >> Command array: " + cmds.inspect
        debug "HelpLoader >> Constructing !help/!commands text..."
        first = true
        cmds.each {|cmd|
            if first
                @helpTxt = "Available commands: " + cmd
                first = false
            else
                @helpTxt = @helpTxt + ", #{cmd}"
            end
        }
    end

    def execute(msg)
        debug "Sending help message to #{msg.channel.name}"
        msg.reply @helpTxt
    end

end