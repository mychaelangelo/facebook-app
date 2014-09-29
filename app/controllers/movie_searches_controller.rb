class MovieSearchesController < ApplicationController
  respond_to :html, :js
  
  require 'httparty'



  def index
    @query = params[:q]
    # APi key (will need to use figaro hide this)
    api_key = ENV['MOVIE_API_KEY']
    search_url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?q=#{params[:q]}&page_limit=10&page=1&apikey=#{api_key}"
    response = HTTParty.get(search_url)
    jsonresult = JSON.parse(response.body)["movies"]
    
    # format json in required format for inputToken jquery 
    # for example [{"id":"770676948","name":"Terminator"},{"id":"11664","name":"The Terminal"}...]
    render json: jsonresult.map{|movie| {:id => movie["id"], :name => movie["title"]}   }
  end


  def show

  end



end
