require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    'Hello world!'
  end

  post '/echo' do
    "#{params[:message]}"
  end
end
