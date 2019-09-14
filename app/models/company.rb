class Company < ApplicationRecord
  has_many :employees, class_name: User.name

  validates :name, presence: true
end
