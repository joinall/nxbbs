
class Topic < ActiveRecord::Base
  validates :title ,  :presence => true, :length => {:within => 5..30}
  validates :content ,:presence => true, :length => {:within => 5..2000}
  
  belongs_to :node
  belongs_to :user
  belongs_to :last_reply_user ,:class_name => "User"

  has_many :replies

#  scope :fields_for_list ,where(:replycount => 0)

end
