class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  attr_reader :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  has_secure_password
  validates :name, presence: true, length: {maximum: Settings.max_user}
  validates :email, presence: true, length: {maximum: Settings.max_email},
    format: {with: VALID_EMAIL_REGEX}
  validates :password, presence: true, length: {minimum: Settings.mini_pass},
    allow_nil: true

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
                BCrypt::Engine::MIN_COST
             else
                BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    @remember_token = User.new_token
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest
    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update remember_digest: nil
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    @reset_token = User.new_token
    update reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.two.hours.ago
  end

  def feed
    microposts
  end

  def current_user? user
    self == user
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    @activation_token  = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
