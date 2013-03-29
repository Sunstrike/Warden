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

require_relative 'PermissionsCheck.rb'

class Kicker
    include Cinch::Plugin
    include Permissions
    class << self
        attr_reader :commands
    end

    @commands = ["!kick"]

    match(/kick/i, method: :kick)

    def kick(msg)
        # Kick user, optionally with custom reason else 'asshat'
        chan = msg.channel
        user = msg.user

        if chan == nil
            return # No channel
        end

        # Check permissions
        kickerPerm = Permissions::accessLevel(chan, user)

        if kickerPerm == :user
            #msg.reply "(#{user.name}) Insufficient permissions."
            return; # Permfail.
        end

        # Parse 
        kickData = /(<.+>)?!kick (\S+) ?(.+)?/i.match(msg.params[1])
        kickable = kickData[2]
        reason = kickData[3]

        if kickable.nil? || kickable == ""
            return
        end

        if reason.nil? || reason == ""
            reason = "asshat"
        end

        kickUser = User(kickable)
        if (kickUser.unknown? || !chan.users.include?(kickUser))
            return
        end

        # Target permissions
        kickeePerm = Permissions::accessLevel(chan, kickUser)

        # Check for superior rank
        if kickerPerm == :voice
            if kickeePerm != :user
                return
            end
        elsif kickerPerm == :halfop
            if kickeePerm != :user && kickeePerm != :voice
                return
            end
        elsif kickerPerm == :op
            if kickeePerm != :user && kickeePerm != :voice && kickeePerm != :halfop
                return
            end
        end

        # We can actually kick now
        chan.kick(kickUser, "(#{user.name}) #{reason}")
    end
end
