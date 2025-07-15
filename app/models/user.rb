class User < ApplicationRecord
  USER_UPDATE_PERRRMITED_ATTRIBUTES = %i[username address phone_number date_of_birth bio].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :username, presence: true
end
