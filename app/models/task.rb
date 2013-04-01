class Task < ActiveRecord::Base
  attr_accessible :completed, :description, :list_id
  validates :description, presence: true,
                          length: { minimum: 10, maximum: 150 }
  validates :list_id, presence: true
  belongs_to :list
end
