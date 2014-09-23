class SuggestionsController < ApplicationController
  def index
    # the similar_movie function looks through user favorites for seed (selected via .sample on array)
    # it then looks through imdb for similar movie and returns a sample of similar movie
    @suggestion = current_user.similar_movie
  end

  def create
    current_user.add_liked(params[:rott_id])
    redirect_to :back
  end

  def destroy
    current_user.add_disliked(params[:rott_id])
    redirect_to :back
  end
end
