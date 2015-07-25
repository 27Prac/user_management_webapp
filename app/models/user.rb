class User < ActiveRecord::Base

	validates :name, :presence => true,
			  :uniqueness => true

	validates :password, :length => {:minimum => 5},
			  :presence => true,
			  :confirmation => true

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, :presence => true,
			  :uniqueness => true,
			  :format => { with: VALID_EMAIL_REGEX }
end
