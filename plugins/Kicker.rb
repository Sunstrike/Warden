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
    class << self
        attr_reader :commands
    end

    @commands = ["!kick"]

    match /kick/i, method: :kick

    def kick(msg)
        # Kick user, optionally with custom reason else 'asshat'
        chan = msg.channel
        user = msg.user

        # Check permissions
        kickerPerm = Permissions::accessLevel(chan, user)

        debug "Kicker perm #{kickerPerm}"

        if kickerPerm == :user
            #msg.reply "(#{user.name}) Insufficient permissions."
            return; # Permfail.
        end

        # Parse 
        debug "Got params array #{msg.params.inspect}"
        
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
            msg.reply "Can't find '#{kickable}'."
            return
        end

        # Target permissions
        kickeePerm = Permissions::accessLevel(chan, kickUser)
        debug "kickUser perm #{kickeePerm}"

        # Check for superior rank
        if kickerPerm == :voice
            if kickeePerm != :user
                msg.reply "(#{user.name}) Cannot kick those of same or higher rank."
                return
            end
        elsif kickerPerm == :halfop
            if kickeePerm != :user && kickeePerm != :voice
                msg.reply "(#{user.name}) Cannot kick those of same or higher rank."
                return
            end
        elsif kickerPerm == :op
            if kickeePerm != :user && kickeePerm != :voice && kickeePerm != :halfop
                msg.reply "(#{user.name}) Cannot kick those of same or higher rank."
                return
            end
        end

        # We can actually kick now
        #msg.reply "(#{user.name}) Kicking '#{kickable}' with reason '#{reason}'."
        chan.kick(kickUser, "(#{user.name}) #{reason}")
    end
end
