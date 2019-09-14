class Company < ApplicationRecord
  has_many :employees, class_name: User.name
end
