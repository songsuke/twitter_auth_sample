class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :omniauthable,
         omniauth_providers: %i(twitter)

  validates :uid, presence: true, uniqueness: { scope: :provider }, unless: :sign_up_by_email?

  def self.from_omniauth(data)
    # Update user when user already exists, and sign in with Twitter
    user = User.find_by_email(data.info.email) if data.info.email.present?
    if user&.uid.nil?
      user.update(provider: data.provider, uid: data.uid)
      user
    end

    # Create user with Twitter
    where(provider: data.provider, uid: data.uid).first_or_create do |user|
      user.email = data.info.email
      user.name = data.info.name
    end
  end

  private def sign_up_by_email?
    email.present? && provider.nil? && uid.nil?
  end

  concerning :OverrideDeviseBehavior do
    # If sign in with Twitter, then the password is not required
    def password_required?
      super && provider.blank?
    end
  end
end
