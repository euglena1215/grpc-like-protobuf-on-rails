(1...30).each do |i|
  User.seed do |u|
    u.id = i
    u.name = "#{("A"..."Z").to_a.sample}・#{("A"..."Z").to_a.sample}"
    u.company_id = (i % Company.count) + 1
    u.monthly = rand(1000000000)
    u.bonus = rand(1000000000000)
  end
end
