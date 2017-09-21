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
    if body == body.starts_with?("what are you d") || body.include?("wryd")
        message = "I'm at the gym lol. Why?"
        sleep 2
        message = "Actually nvm. Idc lol"

      @client.api.account.messages.create(
         from: ENV['TWILIO_FROM'],
         to: params[:From],
         body: "I'm at the gym lol. Why?"
      )
    elsif body == "what are you doing?" || body.include?("are you doing") || body.include?("ryd")
        message = "I'm at the gym lol. Why?"
        sleep (2)
        message = "Actually nvm. Idc."
    elsif body == "Have you done the hw?" || body.include?("hw") || body.include?("homework")
      message = "Yeah a while ago."
    elsif body == "Can you help me?" || body.include?("help me")
      message = "No"
    elsif body == "What is the weather like?" || body.include?("weather")
      message = "Dude look yourself. You have an app"
    elsif body == "Can you remind me to do that thing?" || body.include?("remind")
      message = "Why do you need me to do that? Just set a reminder on your phone"
    else
      message = "(-______-) see ya."
    end

  end
  if session["counter"]==10
    message = "JACK'S PHONE IS ON DO NOT DISTURB NOW. TEXT SOMEONE ELSE."
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
