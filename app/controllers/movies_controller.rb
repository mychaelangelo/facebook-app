class MoviesController < ApplicationController
  def index
    @favorites = current_user.movies_liked
    @dislikes = current_user.movies_disliked
  end 

  def new
    @favorites = current_user.movies_liked
    @search = params[:q]
  end

  def create
    # get params with the liked movie ids
    liked_movies_array = params[:liked_movies].split(",")
    
    # go through list of movie id's and add each to the user's Redis set of liked movies
    liked_movies_array.each do |movie|
      current_user.add_liked(movie)
    end

    redirect_to movies_new_path
  end

  def show
  end

  def edit
  end
end
