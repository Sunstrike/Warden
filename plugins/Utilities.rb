## Warden
##      => Easter eggs
#
# AZI IRC moderation bot
# 
# This file was partly contributed by Hugsim of #Redux!
#

class Hugsim
    include Cinch::Plugin

    match /hugsim/i

    def execute(msg)
        debug "Sending Hugsim message"
        msg.reply "CRAFTINGBENCHES, CRAFTINGBENCHES EVERYWHERE! Hugsim is the guy in the Link skin."
    end
end

class Ecu
    include Cinch::Plugin

    match /ecu/i

    def execute(msg)
        debug "Sending Ecu message"
        msg.reply "OCELOT!"
    end
end

class Bord
    include Cinch::Plugin

    match /bord/i

    def execute(msg)
        debug "Sending Bord message"
        msg.reply "Yes, he is Arnold Schwarzenegger, don't let him fool you! He is also the scary French maid."
    end
end

class NES
    include Cinch::Plugin

    match /uuddlrlrba/i

    def execute(msg)
        debug "Sending Konami message"
        msg.reply "Not here ;)"
    end
end

class Bees
    include Cinch::Plugin

    match /.*bees.*/i, prefix: ""

    def execute(msg)
        debug "Sending BEES! message"
        msg.reply "http://thechive.files.wordpress.com/2010/11/oprah-bees.gif"
    end
end