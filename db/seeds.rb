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
admin_password = ENV['ADMIN_PASSWORD'] || '123456' # Change this in production!

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

  # Create test student
  student = Student.find_or_initialize_by(email: 'test@school.com') do |s|
    s.password = '123456'
    s.password_confirmation = '123456'
    s.first_name = 'Test'
    s.last_name = 'Student'
    s.school = school
  end

  if student.new_record?
    if student.save
      puts "Test student created successfully!"
      puts "Email: test@school.com"
      puts "Password: 123456"
    else
      puts "Failed to create test student:"
      puts student.errors.full_messages
    end
  else
    puts "Test student already exists."
  end

  # Create additional student
  additional_student = Student.find_or_initialize_by(email: 'john.doe@school.com') do |s|
    s.password = '123456'
    s.password_confirmation = '123456'
    s.first_name = 'John'
    s.last_name = 'Doe'
    s.school = school
  end

  if additional_student.new_record?
    if additional_student.save
      puts "Additional student created successfully!"
      puts "Email: john.doe@school.com"
      puts "Password: 123456"
    else
      puts "Failed to create additional student:"
      puts additional_student.errors.full_messages
    end
  else
    puts "Additional student already exists."
  end

  # Create terms
  terms_data = [
    {
      name: 'Fall 2024',
      start_date: Date.new(2024, 9, 1),
      end_date: Date.new(2025, 5, 31), # Expired - before June 2025
      price: 1200.00,
      description: 'Fall semester 2024'
    },
    {
      name: 'Spring 2025',
      start_date: Date.new(2025, 5, 1), # Available - starts in May 2025
      end_date: Date.new(2026, 5, 31), # Ends in May 2026
      price: 1500.00,
      description: 'Spring semester 2025'
    },
    {
      name: 'Fall 2025',
      start_date: Date.new(2025, 12, 1), # Not ready yet - starts in December 2025
      end_date: Date.new(2026, 3, 31),
      price: 1400.00,
      description: 'Fall semester 2025'
    }
  ]

  terms_data.each do |term_attrs|
    term = Term.find_or_create_by!(name: term_attrs[:name], school: school) do |t|
      t.start_date = term_attrs[:start_date]
      t.end_date = term_attrs[:end_date]
      t.price = term_attrs[:price]
    end
    puts "Term created: #{term.name} (#{term.start_date} to #{term.end_date})"
  end

  # Create courses for each term
  course_data = [
    {
      title: 'Introduction to Mathematics',
      description: 'Basic mathematical concepts and problem-solving techniques',
      price: 300.00
    },
    {
      title: 'Advanced Physics',
      description: 'Comprehensive study of classical mechanics and thermodynamics',
      price: 400.00
    },
    {
      title: 'English Literature',
      description: 'Analysis of classic and contemporary literature',
      price: 250.00
    },
    {
      title: 'Computer Science Fundamentals',
      description: 'Programming basics and software development principles',
      price: 350.00
    },
    {
      title: 'World History',
      description: 'Survey of major historical events and their impact',
      price: 280.00
    },
    {
      title: 'Chemistry Lab',
      description: 'Hands-on laboratory experience in chemical reactions',
      price: 320.00
    }
  ]

  # Get all terms for the school
  terms = school.terms

  # Create courses for each term (2 courses per term)
  terms.each_with_index do |term, term_index|
    course_data.each_with_index do |course_attrs, course_index|
      # Create 2 courses per term
      if course_index < 2
        course = Course.find_or_create_by!(title: "#{course_attrs[:title]} - #{term.name}", school: school) do |c|
          c.description = course_attrs[:description]
          c.price = course_attrs[:price]
          c.term = term
        end
        puts "Course created: #{course.title} for #{term.name}"
      end
    end
  end
end
