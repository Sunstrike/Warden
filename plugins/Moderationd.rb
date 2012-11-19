#!/usr/bin/env ruby -wKU

## Warden
##      => Moderation mode module
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

class Moderationd
    include Cinch::Plugin
    include Permissions

    match /mod/i, method: :mod
    match /unmod/i, method: :unmod

    def mod(msg)
        # Put channel into Moderated (+m) mode if user is Voice/Op and channel is not Moderated right now
        chan = msg.channel
        user = msg.user

        # Check for channel already being +m
        if chan.moderated?
            return # No need to act
        end

        # Check user permissions
        if Permissions::check(msg, user, chan)
            msg.reply "#{user.name} is setting channel to MODERATED (+m)"
            chan.moderated = true
        end
    end

    def unmod(msg)
        # Put channel into Unmoderated (-m) mode if user is Voice/Op and channel is Moderated right now
        chan = msg.channel
        user = msg.user

        # Check for channel already being +m
        if !chan.moderated?
            return # No need to act
        end

        # Check user permissions
        if Permissions::check(msg, user, chan)
            msg.reply "#{user.name} is setting channel to UNMODERATED (-m)"
            chan.moderated = false
        end
    end
end