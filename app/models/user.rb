class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable
  include DeviseTokenAuth::Concerns::User
  has_many :user_companies

  def soft_delete
    update_attribute(:deleted_at, Time.current)
  end

  def reactivate_user
    update_attribute(:deleted_at, nil)
  end

  def active_for_authentication?
    super && self.is_active
  end

  def self.is_active
    self.discarded_at == nil
  end

  def is_active
    self.discarded_at == nil
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end
end
