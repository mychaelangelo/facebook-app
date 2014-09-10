class User < ActiveRecord::Base
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

  # Return string value of key for movies_liked, to be used to identify Redis set
  def movies_liked_key
    "user:#{self.id}:movies_liked"
  end

  # Returns the set of movies the user liked
  def movies_liked
    $redis.smembers movies_liked_key
  end

  # Add liked movie
  def add_liked(movie_id)
    $redis.sadd(movies_liked_key, movie_id)
  end



  private
    # assign empty moviesuggestion instance to new user
    def create_movie_suggestion
      self.create_moviesuggestion()
    end



end
