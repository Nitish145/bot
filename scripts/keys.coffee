# Description:
#   partychat like chat-score/leaderboard script built at 'SDSLabs'
#   we developed this to use in our 'Slack' team instance
#
# Commands:
#   listen for * has/have keys in chat text and displays users with the keys/updates the user having keys
#   bot who has keys : returns current user having lab keys
#   bot i have keys : set's the key-holder to the user who posted
#   bot i dont have keys : unsets the user who posted from key-holders
#	bot xyz has keys : sets xyz as the holder of keys
#
# Examples:
#   :bot who has keys
#   :bot i have keys
#   :bot i dont have keys
#	:bot who has keys
#	:bot ravi has keys
#
# Author:
#   Punit Dhoot (@pdhoot)
#   Developer at SDSLabs (@sdslabs)

module.exports = (robot)->

	Keys = ["","","","",""]

	key = ()->
		Keys = robot.brain.get("keys")
		robot.brain.set("keys" ,Keys)
		Keys

	
	robot.respond /i have (a key|the key|key|keys)/i, (msg)->
		name = msg.message.user.name 
		user = robot.brain.userForName name
		k = key()
		if typeof user is 'object'
			count = 0
			msg.send "Okay #{name} has keys"
			while count < k.length
				if k[count] == ""
					do k[count] = user.name
					count++;
					break
		robot.brain.set("keys",k)		


	robot.respond /i (don\'t|dont|do not) (has|have) (the key|key|keys|a key)/i , (msg)->
		name = msg.message.user.name
		user = robot.brain.userForName name
		k = key()
		count = 0
		while count < k.length
			if k[count] == name
				do k[count] = ""
				count++;
				break
		if typeof user is 'object'
			count = 0
			while count < k.length
				if k[count] == ""
					msg.send "Okay #{name} doesn't have keys. Who got the keys then?"
					count++;
					break
				else
					msg.send "Yes , i know buddy, its because #{k} has got the keys"	
		robot.brain.set("keys",k)	


	robot.respond /(.+) (has|have) (the key|key|keys|a key)/i , (msg)->
		othername = msg.match[1]
		name = msg.message.user.name
		k = key()
		unless othername in ["who", "who all","Who", "Who all" , "i" , "I" , "i don't" , "i dont" , "i do not" , "I don't" , "I dont" , "I do not"]
			if othername is 'you'
				msg.send "How am I supposed to take those keys? #{name} is a liar!"
			else if othername is robot.name
				msg.send "How am I supposed to take those keys? #{name} is a liar!"
			else
				users = robot.brain.usersForFuzzyName othername
				if users.length is 1
					count = 0
					while count < k.length
						if k[count] == ""
							k[count] = users[0].name
							count++;
							break
					robot.brain.set("keys",k)
					msg.send "Okay, so now the keys are with #{users[0].name}"
				else if users.length > 1
					msg.send getAmbiguousUserText users
				else
					msg.send "#{othername}? Never heard of 'em"

	robot.respond /(i|I) (have given|gave|had given) (the key|key|keys|a key|the keys) to (.+)/i , (msg)->
		othername = msg.match[4]
		name = msg.message.user.name
		k = key()
		if othername is 'you'
			msg.send "That's utter lies! How can you blame a bot to have the keys?"
		else if othername is robot.name
			msg.send "That's utter lies! How can you blame a bot to have the keys?"
		else
			users = robot.brain.userForName othername
			if users is null
				msg.send "I don't know anyone by the name #{othername}"
			else
			count = 0
			while count < k.length
				if k[count] == name
					k[count] = othername
					count++;
					break
				msg.send "Okay, so now the keys are with #{users.name}"		

		robot.brain.set("keys",k)		
				
	robot.respond /(who|who all) (has|have) (the key|key|keys|a key)/i , (msg)->
		k = key()
		msgText = "The current key holders are "
		count = 0
		while count < k.length
			if k[count] != ""
				msgText+= k[count]+" "

			robot.brain.set("keys" ,k)


getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

