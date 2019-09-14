class SalaryPolicy < ApplicationPolicy
  def get_salary?
    # 自身の給与は見ることができる
    is_mime = request.user_id == context.user_id

    # 部長以上であれば同じ会社に属している人の給与を見ることができる
    is_my_junior = bucho_or_more? && User.exists?(company_id: context.company_id, id: request.id)

    is_mime || is_my_junior
  end

  def list_salary?
    # TODO: impl
    true
  end

  def double_bonus?
    # TODO: impl
    true
  end

  def update_monthly_salary?
    # TODO: impl
    true
  end
end
