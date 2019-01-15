class User < ApplicationRecord
  validates :name, presence: true, length: {maximun: Settings.max_user}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximun: Settings.max_email},
  format: {with: VALID_EMAIL_REGEX},
  uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimun: Settings.max_pass}
end
