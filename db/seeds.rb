# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user if it doesn't exist
admin_email = ENV['ADMIN_EMAIL'] || 'admin@school.com'
admin_password = ENV['ADMIN_PASSWORD'] || 'kaizen1234' # Change this in production!

admin = Admin.find_or_initialize_by(email: admin_email) do |user|
  user.password = admin_password
  user.password_confirmation = admin_password
  user.first_name = 'System'
  user.last_name = 'Administrator'
end

if admin.new_record?
  if admin.save
    puts "Admin user created successfully!"
    puts "Email: #{admin_email}"
    puts "Password: #{admin_password}"
  else
    puts "Failed to create admin user:"
    puts admin.errors.full_messages
  end
else
  puts "Admin user already exists."
end

# Create a sample school for development
if Rails.env.development?
  school = School.find_or_create_by!(name: 'Kaizen Academy Demo') do |s|
    s.status = 'active'
  end
  puts "Sample school created: #{school.name}"
end
