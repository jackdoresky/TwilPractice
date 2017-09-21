require "sinatra"
require 'sinatra/reloader' if development?
require 'twilio-ruby'
enable :sessions
@client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
configure :development do
  require 'dotenv'
  Dotenv.load
end
get "/" do
    404
end
get "/sms/incoming" do
  session["last_intent"] ||= nil
  session["counter"] ||= 1
  count = session["counter"]
  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip


  @client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  if session["counter"] == 1
    message = "What's up?"

  elsif session["counter"]>=1
    if body.include?("wryd")
        message = "I'm at the gym lol. Why?"

      @client.api.account.messages.create(
         from: ENV['TWILIO_FROM'],
         to: params[:From],
         body: "I'm at the gym lol. Why?"
      )
    elsif body.include?("are you doing")
        message = "I'm at the gym lol. Why?"

    elsif body.include?("hw") || body.include?("homework")
      message = "Yeah a while ago."
    elsif body.include?("help")
      message = "No"
    elsif body.include?("weather")
      message = "Dude look yourself. You have an app"
    elsif body == "Can you remind me to do that thing?" || body.include?("remind")
      message = "Why do you need me to do that? Just set a reminder on your phone"
    elsif body.include?("jack")
      message = "jack? That's a cool kid. That's all you need to know"
    elsif body.include?("more")
      message = "I've said too much already"
    elsif body.include?("please")
      message = "https://media.giphy.com/media/26uf1obq3ifbbixVK/giphy.gif"
    else
      message = "We're done here."
    end

  end
  if session["counter"]==10
    message = "JACK'S PHONE IS ON DO NOT DISTURB NOW. TEXT SOMEONE ELSE."
    media = nil
  end
  if session["counter"]>=11
    message = "https://media.giphy.com/media/26uf1obq3ifbbixVK/giphy.gif"
    media = nil
  end
  session["counter"] += 1
  twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|
      m.body( message )
      unless media.nil?
        m.media( media )
      end
    end
  end
  content_type 'text/xml'
  twiml.to_s
end
