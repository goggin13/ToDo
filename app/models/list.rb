class List < ActiveRecord::Base
  attr_accessible :title, :user_id

  validates :title, presence: true,
                    length: { minimum: 5, maximum: 50 }
  validates :user_id, presence: true

  belongs_to :user
  has_many :tasks
end
