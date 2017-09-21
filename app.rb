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

  if session["counter"] == 1
    message = "Thanks for your first message. From #{sender} saying #{body}"
    media = "https://media.giphy.com/media/13ZHjidRzoi7n2/giphy.gif"
  end
  if body == "What are you doing" || body == "wryd"
    message = "I'm at the gym lol. Why?"
    sleep (2)
    message = "Actually nvm. Idc lol"
  end
  if body == "Have you done the hw yet?"
    message = "Yeah a while ago."
    if == "Can you help me"
      message = "No"
    else == "We're done here."
    end
  end

  else
    message = "I am sleeping. Don't bother me rn."
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
