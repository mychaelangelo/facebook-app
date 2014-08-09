class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #override redirect page after sign in
  def after_sign_in_path_for(resource)
    # will redirect user to the recommendation page
    recommend_path
  end
end
