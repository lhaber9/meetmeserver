require "rubygems"
require "bundler/setup"
require "sinatra"
require "pubnub"
require File.join(File.dirname(__FILE__), "environment")

configure do
  
  set :pubnub, Pubnub.new(subscribe_key: 'sub-c-a57136cc-9870-11e5-b53d-0619f8945a4f', 
	  					   publish_key: 'pub-c-630fe092-7461-4246-b9ba-a6b201935fb7')

  set :views, "#{File.dirname(__FILE__)}/views"
  set :show_exceptions, :after_handler
end

configure :production, :development do
  enable :logging
end

helpers do
  # add your helpers here
  def send_pubnub(msg, channelName, timerId)
  	puts channelName
  	settings.pubnub.publish(
  		channel: channelName,
  		message: msg
  	) do |e|
  		puts e.parsed_response
  	end
  end
end

get "/v1/setTimer/:channelId/:numOfSeconds/:timerId" do

	seconds = params[:numOfSeconds].to_i
	channelName = params[:channelId]
	timerId = params[:timerId].to_i

	Thread.new {
		sleep seconds
		send_pubnub("Timer Done",channelName,timerId)
	}

	if seconds > 30
		Thread.new {
			sleep seconds - 30
			send_pubnub("30 Second Warning",channelName, timerId)
		}
	end
end

post "/v1/cancelTimer/:timerId" do 

	

end