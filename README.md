## Overview

Kaizen Academy is a Ruby on Rails application designed to provide a platform for continuous improvement and learning. The project is set up with the following features and configurations:

- **Rails Version**: 8.0.2
- **Database**: SQLite3
- **Testing Framework**: RSpec

### Core Features

- **Multi-Role System**: Supports two user roles—`Admin` and `Student`—using Single Table Inheritance (STI).
- **Admin Dashboard**: Admins can manage schools, terms, courses, and view student information.
- **Course & Term Management**: Admins can create and manage terms within a school and the courses offered in each term.
- **Student Enrollment**: Students are associated with a school and can enroll in courses.
- **Flexible Purchasing Options**: Students can gain access to courses either by purchasing a subscription to a whole `Term` or by buying a `Course` individually.
- **License-Based Access**: Admins can generate unique license codes for term subscriptions, which students can redeem for access.
- **Direct Payments**: A simulated credit card payment system for direct purchases.

## System Initial Instructions

### Prerequisites

- Ruby 3.4.4
- Rails 8.0.2
- SQLite3

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/hielf/kaizen_academy.git
   cd kaizen_academy
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```
4. Precompile assets:
   ```bash
   rails assets:precompile
   ```

5. Start the Rails server:
   ```bash
   rails s
   ```

6. Open your browser and navigate to `http://localhost:3000` to view the application.
   - Admin Username: admin@school.com
   - Password: 123456

   ---

   - Student Username: test@school.com
   - Password: 123456

### Running Tests

To run the tests using RSpec, execute the following command:
```bash
rspec
```

### Additional Information

 [Domain Models](DOMAIN_MODELS.md)

