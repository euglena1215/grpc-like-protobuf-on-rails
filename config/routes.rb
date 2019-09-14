Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :salaries, only: [] do
    patch :get_salary
    patch :list_salary
    patch :double_bonus
    patch :update_monthly_salary
  end
end
