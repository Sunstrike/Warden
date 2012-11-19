#!/usr/bin/env ruby -wKU

## Warden
##      => Kicker module
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

require_relative 'PermissionsCheck.rb'

class Kicker
    include Cinch::Plugin
    include Permissions

    match /kick/i, method: :kick

    def kick(msg)
        # Kick user, optionally with custom reason else 'asshat'
        chan = msg.channel
        user = msg.user
        # Check permissions
        if !Permissions::check(msg, user, chan)
            return
        end

        # Parse 
        debug "Got params array #{msg.params.inspect}"
        
        kickData = /!kick (\w+) ?(.+)?/i.match(msg.params[1])
        kickable = kickData[1]
        reason = kickData[2]

        if kickable.nil? || kickable == ""
            return
        end

        if reason.nil? || reason == ""
            reason = "asshat"
        end

        kickUser = User(kickable)
        tmp = chan.users[kickUser]?
        if kickUser.unknown? || !tmp
            msg.reply "I can't find #{kickable} to kick."
            return
        end

        # We can actually kick now
        msg.reply "(#{user.name}) Kicking '#{kickable}' with reason '#{reason}'."
        chan.kick(kickUser, reason)
    end
end
