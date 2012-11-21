class Reply < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user 

  validates :content ,  :presence => true, :length => {:within => 2..2000}
end
