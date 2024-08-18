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
        response += "\n-# i'm sowwy, i twied my best ;-;"
      else
        response += "\n-# maybe twy saying \"pwease\" next time?"
      end
      # response += "\n-# I'm sorry!"
      # response += "\nDebug: I think you rolled a #{raw_roll}"
    elsif raw_roll == x_value
      if (user_was_polite)
        response += "\n-# >w<"
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

  maybe_message=try_say
  response += "\nDebug: #{maybe_message}" unless maybe_message.empty?

  response
end

messages = [
    "1",  # 1 - Empty string
    "2Keep going!",  # 2
    "3Nice roll!",  # 3
    "4",  # 4 - Empty string
    "5Try again!",  # 5
    "6",  # 6 - Empty string
    "7You got this!",  # 7
    "8Excellent!",  # 8
    "9",  # 9 - Empty string
    "10Almost there!"  # 10
  ]

def try_say
  # Perform a 1d100 roll to decide if/which message to return
  roll_result = DiceBag::Roll.new('1d100').result.total
  statement = ""
  statement += "\nDebug: rolled #{roll_result}"
  if (roll_result < 11)
    statement += messages[roll_result - 1]
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
