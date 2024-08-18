# frozen_string_literal: true

def build_response
  response = "#{@user} Request: `[#{@roll_request.strip}]`"
  if @roll_set
    response += if @comment.to_s.empty? || @comment.to_s.nil?
                  " Rolls:\n#{@roll_set_results}Results Total: `#{@roll_set_total}`"
                else
                  " Rolls:\n#{@roll_set_results}Results Total: `#{@roll_set_total}`\nReason: `#{@comment}`"
                end
    return response
  end
  unless @simple_output
    response += " Roll: `#{@tally}`"
    response += " Rerolls: `#{@reroll_count}`" if @show_rerolls
  end
  response += botch_counter if @show_botch
  response += " #{@dice_result}" unless @no_result

  response += " Body: `#{@hsn_body}`, Stun: `#{@hsn_stun}`" if @hsn

  response += " Body: `#{@hsk_body}`, Stun Multiplier: `#{@hsk_multiplier}`, Stun: `#{@hsk_stun}`" if @hsk

  response += " Hits DCV `#{@dice_result.scan(/\d+/)}`" if @hsh

  response += " Reason: `#{@comment}`" if @has_comment

  # Beginning of Waifu response programming

  # Recognize user politeness
  # Check both @roll_request and @comment for at least one instance of "please", "pwease", or "plz", case-insensitive
  # (why @roll_request? because if it's not a properly formatted comment with a ! the user's message stays there)
  # (why not check the whole message? in case the user has "please" in their name, and so they can't escape my logic to ignore their name)
  
  # if @roll_request.match?(/please|pwease|plz/i) || @comment.match?(/please|pwease|plz/i)
  #  response = "I'll try!\n" + response
  # end

  

  # Detect if a single die roll was a minimum or maximum roll (as it's likely a critical fail or success)

  # Check if the roll request contains "1dX" and capture the value of X, if X is greater than or equal to 6 (coin flips aren't very lucky)
  if (x_value = @roll_request.match(/1d([6-9]|\d{2,})/i))
    x_value = x_value[1].to_i
    # response += "\nDebug: I think you're rolling a d#{x_value}"

    # Recognize user politeness
    # Check both @roll_request and @comment for at least one instance of "please", "pwease", or "plz", case-insensitive
    # (why @roll_request? because if it's not a properly formatted comment with a ! the user's message stays there)
    # (why not check the whole message? in case the user has "please" in their name, and so they can't escape my logic to ignore their name)

    # user_was_polite = (response.match?(/please|pwease|plz/i) || @comment.match?(/please|pwease|plz/i))
    
    user_was_polite = (response.match?(/p+l+e+a+s+e+|p+w+e+a+s+e+|p+l+z+/i) || @comment.match?(/p+l+e+a+s+e+|p+w+e+a+s+e+|p+l+z+/i))
    # allows repeated letters
    
    #user_was_polite = (response.match?(/\A(?=.*p)(?=.*l)(?=.*e)(?=.*a)(?=.*s)[pleas]+\z/i) ||
    #               response.match?(/\A(?=.*p)(?=.*w)(?=.*e)(?=.*a)(?=.*s)[pweas]+\z/i) ||
    #               response.match?(/\A(?=.*p)(?=.*l)(?=.*z)[plz]+\z/i) ||
    #               @comment.match?(/\A(?=.*p)(?=.*l)(?=.*e)(?=.*a)(?=.*s)[pleas]+\z/i) ||
    #               @comment.match?(/\A(?=.*p)(?=.*w)(?=.*e)(?=.*a)(?=.*s)[pweas]+\z/i) ||
    #               @comment.match?(/\A(?=.*p)(?=.*l)(?=.*z)[plz]+\z/i))
    # allows the letters to be in any order and number as long as there are no incorrect letters in the word

    # user_is_leeroy = @user.downcase.include?("leeroy")
    
    # if @roll_request.match?(/please|pwease|plz/i) || @comment.match?(/please|pwease|plz/i)
    #  response = "I'll try!\n" + response
    # end

    # Get the raw dice roll from the tally (which will be a single integer, since we rolled 1dX and didn't do Y 1dX)
    raw_roll = @tally.match(/\d+/)[0].to_i
    
    # Compare raw_roll with 1 and X
    # response += "\nDebug: @tally = '#{@tally}'"
    if raw_roll == 1
      if (user_was_polite)
        maybe_message=try_say("oops")
        response += "\n-# #{maybe_message}" unless maybe_message.empty?
        
        # response += "\n-# i'm sowwy, i twied my best ;-;"
      else
        maybe_message=try_say("hint")
        response += "\n-# #{maybe_message}" unless maybe_message.empty?
        
        # response += "\n-# maybe twy saying \"pwease\" next time?"
      end
      # response += "\n-# I'm sorry!"
      # response += "\nDebug: I think you rolled a #{raw_roll}"
    elsif raw_roll == x_value
      if (user_was_polite)
        maybe_message=try_say("yay")
        response += "\n-# #{maybe_message}" unless maybe_message.empty?
        
        # response += "\n-# >w<"
      else
      end
      # response += "\n-# Yay!"
      # response += "\nDebug: I think you rolled a #{raw_roll}"
    else
      # response += "\nDebug: I think you rolled a #{raw_roll}"
    end
  else
  # response += "\nDebug: I don't think you rolled 1dsomething"
  end

  

  response
end

YAY_MESSAGES = [
    ">w<",  # 1
    "hehe",  # 2
    "we did it!",  # 3
    "i twied extwa hard dat time!",  # 4
    "just for you <3",  # 5
    "i knew we could do it!",  # 6
    "i hope dis was an impotant woll!",  # 7
    "yes! teamwork!",  # 8
    "OwO, what's dis?",  # 9 
    "cwitical success!"  # 10
  ]

OOPS_MESSAGES = [
    "i'm weally sowwy...",  # 1
    "i twied so hard...",  # 2
    ";-;",  # 3
    "oops...",  # 4 -
    ">///<",  # 5
    "i twied my best...",  # 6 
    "i hope dis wasn't impotant...",  # 7
    "can i twy again!",  # 8
    "oh no",  # 9 -
    "cwitical fail..."  # 10
  ]

HINT_MESSAGES = [
    "it'd be nice if you asked powitewy...",  # 1 
    "have you twied saying \"pwease\"?",  # 2
    "did you know there's a \"plz\" modifier? i mean, not weally, but...",  # 3
    "maybe you'd have better luck if you asked nicewy?",  # 4 
    "maybe twy saying de magic word?",  # 5
    "maybe if you were more powite?",  # 6 
    "you can be powite before or aftuh your dice, or in de ! comment",  # 7
    "\"pweeeaase\" would work, as wong as de wettuhs are in de wight orduh",  # 8
    "\"please\" and \"pwease\" bohf work. \"plz\" works, too!",  # 9 
    "my powiteness ow-go-wivvim isn't case-sensitive, btw"  # 10
  ]

def try_say(type)
  statement = ""
  if (type != "yay" && type != "oops" && type != "hint")
    statement += "\nDebug: \"#{type}\" is not a valid try_say type\n"
  end
  # Perform a 1d100 roll to decide if/which message to return
  roll_result = DiceBag::Roll.new('1d100').result.total
  
  # statement += "\nDebug: rolled #{roll_result}"
  if (type == "yay")
    if (roll_result < 11)
      statement += YAY_MESSAGES[roll_result - 1]
    end
  elsif (type == "oops")
    if (roll_result < 11)
      statement += OOPS_MESSAGES[roll_result - 1]
    end
  else # can only be "hint"
    if (roll_result < 11)
      statement += HINT_MESSAGES[roll_result - 1]
    end
  end
  
  return statement
end

def send_response(event)
  # Print dice results to Discord channel
  # reduce noisy errors by checking if response array is empty due to responding earlier
  if @response_array.empty?
    # do nothing
  elsif check_wrath == true
    respond_wrath(event, @dnum)
  elsif @private_roll
    event.respond(content: @response_array.join("\n").to_s, ephemeral: true)
  else
    event.respond(content: @response_array.join("\n").to_s)
    check_fury(event)
  end
end
