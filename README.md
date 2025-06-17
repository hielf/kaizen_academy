Kaizen Academy is a Ruby on Rails application designed to provide a platform for continuous improvement and learning. The project is set up with the following features and configurations:

- **Rails Version**: 8.0.2
- **Database**: SQLite3
- **Testing Framework**: RSpec

## System Initial Instructions

### Prerequisites

- Ruby 3.4.4
- Rails 8.0.2
- SQLite3

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
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
   ```

4. Start the Rails server:
   ```bash
   rails s
   ```

5. Open your browser and navigate to `http://localhost:3000` to view the application.

### Running Tests

To run the tests using RSpec, execute the following command:
```bash
rspec
```

### Additional Information

 [Domain Models](DOMAIN_MODELS.md).

