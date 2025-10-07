# WellnessConnect

A professional services marketplace platform connecting clients with qualified service providers for virtual consultations and sessions.

## Overview

WellnessConnect enables qualified professionals (wellness coaches, therapists, consultants, tutors, etc.) to offer their services online and manage client sessions efficiently. Clients can browse providers, book sessions, and manage their consultations through an intuitive web interface.

## Key Features

### For Clients
- Browse and search service providers by specialty, price, and availability
- View detailed provider profiles with credentials and services
- Book sessions with available time slots
- Manage appointments and payment history
- Secure payment processing via Stripe

### For Service Providers
- Create professional profiles with credentials and specialties
- List multiple services with custom pricing
- Manage availability schedules
- Take private session notes (encrypted)
- Track appointments and client interactions

### For Administrators
- User management and moderation
- Platform oversight and support
- Payment dispute resolution
- Analytics and reporting

## Technology Stack

- **Framework**: Ruby on Rails 8.1.0.beta1 (edge Rails)
- **Ruby Version**: 3.4.3
- **Database**: PostgreSQL (multiple databases for primary, cache, queue, cable)
- **Authentication**: Devise
- **Authorization**: Pundit (policy-based)
- **Payment Processing**: Stripe
- **File Storage**: Active Storage with Tigris (S3-compatible)
- **Background Jobs**: Solid Queue (Rails 8)
- **Caching**: Solid Cache (Rails 8)
- **WebSockets**: Solid Cable (Rails 8)
- **Frontend**: Hotwire (Turbo + Stimulus), TailwindCSS
- **Deployment**: Fly.io with Docker

## Prerequisites

- Ruby 3.4.3
- PostgreSQL 16+
- Node.js 18+ (for JavaScript bundling)
- Yarn or npm
- Redis (for development/test environments)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/wellness_connect.git
cd wellness_connect
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
yarn install
# OR
npm install
```

### 3. Setup Database

```bash
# Create database, run migrations, and seed data
bin/setup

# Or run individually:
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

### 4. Configure Environment Variables

Copy the example environment file and update with your credentials:

```bash
cp .env.example .env
```

Required environment variables for development:
```
DATABASE_URL=postgresql://localhost/wellness_connect_development
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

### 5. Start the Development Server

```bash
# Start Rails server and Tailwind CSS watcher
bin/dev

# Or start separately:
bin/rails server          # Rails server on port 3000
bin/rails tailwindcss:watch  # Tailwind CSS watcher
```

Visit http://localhost:3000 to see the application.

## Running Tests

```bash
# Run all tests
bin/rails test

# Run specific test types
bin/rails test:models
bin/rails test:controllers
bin/rails test:system

# Run specific test file
bin/rails test test/models/user_test.rb

# Run with coverage
COVERAGE=true bin/rails test
```

## Code Quality

```bash
# Run RuboCop linter
bin/rubocop

# Auto-correct safe offenses
bin/rubocop -a

# Run security scanner
bin/brakeman

# Check for vulnerable dependencies
bundle-audit
```

## Deployment

### Fly.io Deployment

The application is configured for deployment on Fly.io with Tigris storage for file uploads.

**Quick Deploy:**

```bash
# 1. Install Fly.io CLI
curl -L https://fly.io/install.sh | sh

# 2. Authenticate
fly auth login

# 3. Create app and infrastructure (first time only)
fly launch --name wellness-connect --region lhr --no-deploy
fly postgres create --name wellness-connect-db --region lhr
fly postgres attach wellness-connect-db --app wellness-connect
fly storage create --name wellness-connect-storage --org personal --app wellness-connect

# 4. Set secrets
fly secrets set RAILS_MASTER_KEY="$(cat config/master.key)" --app wellness-connect

# 5. Deploy
fly deploy --app wellness-connect

# 6. Open application
fly open --app wellness-connect
```

**Detailed Deployment Guide:**

For comprehensive deployment instructions, see:
- 📘 [Fly.io Tigris Storage Setup](docs/FLYIO_TIGRIS_SETUP.md)
- ✅ [Deployment Checklist](docs/DEPLOYMENT_CHECKLIST.md)

**Common Deployment Commands:**

```bash
# View logs
fly logs --app wellness-connect -f

# SSH into application
fly ssh console --app wellness-connect

# Rails console
fly ssh console --app wellness-connect
/rails/bin/rails console

# Database console
fly postgres connect -a wellness-connect-db

# Scale application
fly scale vm shared-cpu-2x --memory 2048 --app wellness-connect
fly scale count 2 --app wellness-connect

# Rollback deployment
fly releases rollback --app wellness-connect
```

## Project Structure

```
wellness_connect/
├── app/
│   ├── controllers/      # Request handlers
│   ├── models/          # Data models and business logic
│   ├── views/           # ERB templates
│   ├── policies/        # Pundit authorization policies
│   ├── jobs/            # Background jobs (Solid Queue)
│   ├── mailers/         # Email templates and logic
│   └── javascript/      # Stimulus controllers
├── config/
│   ├── environments/    # Environment-specific configuration
│   ├── initializers/    # Framework and gem configuration
│   ├── locales/         # I18n translations
│   ├── database.yml     # Database configuration
│   └── storage.yml      # Active Storage configuration
├── db/
│   ├── migrate/         # Database migrations
│   └── seeds.rb         # Seed data
├── docs/               # Project documentation
│   ├── FLYIO_TIGRIS_SETUP.md
│   ├── DEPLOYMENT_CHECKLIST.md
│   └── IMPLEMENTATION_GUIDES.md
├── test/
│   ├── models/         # Model tests
│   ├── controllers/    # Controller tests
│   ├── system/         # End-to-end browser tests
│   └── fixtures/       # Test data
├── Dockerfile          # Production Docker image
├── fly.toml           # Fly.io deployment configuration
└── CLAUDE.md          # Claude Code assistant context
```

## Data Model

### Core Models

- **User**: Central identity model with roles (patient/client, provider, admin)
- **ProviderProfile**: Extended information for service providers
- **PatientProfile**: Client-specific information
- **Service**: Provider offerings (sessions, consultations)
- **Availability**: Provider time slots for booking
- **Appointment**: Scheduled sessions between client and provider
- **Payment**: Stripe-integrated payment tracking
- **ConsultationNote**: Provider's private session notes (encrypted)

See [CLAUDE.md](CLAUDE.md) for detailed data architecture and relationships.

## Development Workflow

### Git Workflow

**ALWAYS follow this workflow for every task:**

1. Create a new feature branch:
   ```bash
   git checkout -b feature/feature-name
   ```

2. Follow Test-Driven Development (TDD):
   - Write failing tests first
   - Implement code to make tests pass
   - Refactor while keeping tests green

3. Run tests before committing:
   ```bash
   bin/rails test
   bin/rubocop
   ```

4. Commit with meaningful messages:
   ```bash
   git add .
   git commit -m "feat: add provider availability management"
   ```

5. Push and create Pull Request:
   ```bash
   git push -u origin feature/feature-name
   ```

### Commit Message Convention

- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `docs:` - Documentation changes
- `style:` - Code style changes
- `chore:` - Maintenance tasks

## Configuration

### Environment Variables

**Development:**
- `DATABASE_URL` - PostgreSQL connection string
- `STRIPE_PUBLISHABLE_KEY` - Stripe public key
- `STRIPE_SECRET_KEY` - Stripe secret key

**Production (Fly.io):**
- `RAILS_MASTER_KEY` - Rails credentials encryption key
- `DATABASE_URL` - PostgreSQL connection (auto-set by Fly.io)
- `AWS_ACCESS_KEY_ID` - Tigris storage access key
- `AWS_SECRET_ACCESS_KEY` - Tigris storage secret key
- `AWS_ENDPOINT_URL_S3` - Tigris endpoint
- `BUCKET_NAME` - Tigris bucket name

See `fly.toml` for complete list of required secrets.

## Security

### Security Features

- ✅ Content Security Policy (CSP) configured
- ✅ HTTPS forced in production
- ✅ Secure session cookies
- ✅ CSRF protection enabled
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS protection (automatic output escaping)
- ✅ Encrypted consultation notes
- ✅ Environment-based secrets management
- ✅ Rate limiting (future enhancement)

### Security Best Practices

1. **Never commit secrets**: Use environment variables
2. **Run security scans**: `bin/brakeman` before deployment
3. **Update dependencies**: `bundle update` regularly
4. **Review logs**: Monitor for suspicious activity
5. **Rotate credentials**: Change passwords and API keys periodically

## Troubleshooting

### Common Issues

**Database connection errors:**
```bash
# Check PostgreSQL is running
brew services list | grep postgresql  # macOS
sudo service postgresql status        # Linux

# Recreate database
bin/rails db:drop db:create db:migrate db:seed
```

**Asset issues (Tailwind not updating):**
```bash
bin/rails assets:clobber
bin/rails tailwindcss:build
# Or use dev server which auto-watches
bin/dev
```

**Test failures after migration:**
```bash
RAILS_ENV=test bin/rails db:reset
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Commit your changes (`git commit -m 'feat: add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Code Review Checklist

- [ ] Tests pass and coverage is adequate
- [ ] No security vulnerabilities
- [ ] Performance impact considered
- [ ] Error handling comprehensive
- [ ] Documentation updated
- [ ] Follows project conventions
- [ ] No commented-out code
- [ ] Logging appropriate

## Documentation

- 📘 [Claude Code Context](CLAUDE.md) - Project overview and technical details
- 📘 [Fly.io Tigris Storage Setup](docs/FLYIO_TIGRIS_SETUP.md) - Cloud storage configuration
- ✅ [Deployment Checklist](docs/DEPLOYMENT_CHECKLIST.md) - Complete deployment guide
- 📘 [Implementation Guides](docs/IMPLEMENTATION_GUIDES.md) - Testing and feature implementation guides

## Support

For issues or questions:
- **Bugs**: Create an issue on GitHub
- **Questions**: Discussion board or team Slack
- **Security**: Email security@example.com

## License

This project is proprietary and confidential.

## Acknowledgments

- Built with Ruby on Rails 8
- Styled with TailwindCSS
- Deployed on Fly.io
- Storage powered by Tigris
