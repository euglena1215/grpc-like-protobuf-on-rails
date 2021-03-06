class User < ApplicationRecord
  belongs_to :company

  validates :name, presence: true, length: { maximum: 100 }

  def double_bonus!
    update!(bonus: bonus * 2)
  end

  def to_pb_salary_message
    SalaryPb::Salary.new(
      monthly: monthly,
      bonus: bonus,
      user_id: id
    )
  end
end
