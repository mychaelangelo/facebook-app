class User < ActiveRecord::Base
  #include RottenTomatoes API wrapper from https://github.com/nmunson/rottentomatoes
  include RottenTomatoes
  


  # After new user create, assign to them a blank moviesuggestion instace
  after_create :create_movie_suggestion

  # each user will have one moviesuggestion instance
  has_one :moviesuggestion, dependent: :destroy    


  #Omniauth tutorial code
  ######
  ######
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.extra.raw_info.name,
          #username: auth.info.nickname || auth.uid,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20]
        )
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end
  # End of Omniauth tutorial code
  ######
  ######

  #### REDIS-BASED FUNCTIONS
  ###

  # - LIKED MOVIES
  # Return string value of key for movies_liked, to be used to identify Redis set
  def movies_liked_key
    "user:#{self.id}:movies_liked"
  end

  # Returns the set of movies the user liked
  def movies_liked
    REDIS.smembers movies_liked_key
  end

  # Add liked movie
  def add_liked(movie_id)
    REDIS.sadd(movies_liked_key, movie_id)
  end

  # - DISLIKED MOVIES
  # Return string value of key for movies_disliked, to be used to identify Redis set
  def movies_disliked_key
    "user:#{self.id}:movies_disliked"
  end

  # Returns the set of movies the user liked
  def movies_disliked
    REDIS.smembers movies_disliked_key
  end

  # Add disliked movie
  def add_disliked(movie_id)
    REDIS.sadd(movies_disliked_key, movie_id)
  end

  # Clear all liked movies set
  def clear_liked
    REDIS.del movies_liked_keye
  end



  #### RECOMMENDATION ALGORITHM

  # step 1: pick random sample from list of liked movies (use 'movies_liked.sample' function)
  # step 2: connect to rotten tomatoes API, and use similar-movies call with the sample from step 1 as source
  # step 3: add the movie found to 'recommended list', unless it's already there, in which case find another movie
  # step 4: wait on user to say if 'like' or 'dislike' and also store movie in appropriate place
  
  # Set my rotten tomatoes API key
  Rotten.api_key = "hhwvunztsczvsw3yusb768t7"



  def recommend
    # pick sample from liked_movies
    seed_movie_id = self.movies_liked.sample

    @movie = RottenList.find(:id => seed_movie_id, :similar => true, :limit => 5)
    @movie.sample
  end



  private
    # assign empty moviesuggestion instance to new user
    def create_movie_suggestion
      self.create_moviesuggestion()
    end



end
