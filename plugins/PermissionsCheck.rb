#!/usr/bin/env ruby -wKU

## Warden
##      => Permissions checker
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

module Permissions
    def check(msg, user, chan)
        if chan.voiced?(user) || chan.half_opped?(user) || chan.opped?(user)
            return true
        else
            msg.reply "#{user.name} has insufficient rank. (+v/+h/+o)"
            return false
        end
    end

    module_function :check

    def strictCheck(msg, user, chan)
        if user.authed?
            return check(msg, user, chan)
        else
            msg.reply "#{user.name} is not registered with NickServ."
            return false
        end
    end

    module_function :strictCheck

    def accessLevel(chan,user)
        if chan.owners.include?(user)
            return :owner
        elsif chan.opped?(user)
            return :op
        elsif chan.half_opped?(user)
            return :halfop
        elsif chan.voiced?(user)
            return :voice
        else
            return :user # No permission
        end
    end

    module_function :accessLevel
end