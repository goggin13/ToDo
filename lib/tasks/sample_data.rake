namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    5.times do 
      User.create!(email: Faker::Internet.email,
                   password: "password",
                   password_confirmation: "password")
    end
    User.all.each do |user|
      5.times { user.lists.create! title: Faker::Company.bs }
    end
    List.all.each do |list|
      10.times { list.tasks.create! description: Faker::Lorem.sentence(10) }
    end    
  end
end
