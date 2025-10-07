# Deployment Checklist for Fly.io

This checklist ensures all configuration and setup steps are completed before deploying WellnessConnect to production on Fly.io.

## Pre-Deployment Setup

### 1. Application Configuration

- [x] **Rails 8 Configuration**
  - [x] `config/environments/production.rb` configured
  - [x] Solid Queue configured for background jobs
  - [x] Solid Cache configured for caching
  - [x] Solid Cable configured for WebSockets
  - [x] Active Storage configured for Tigris
  - [x] Content Security Policy (CSP) configured
  - [x] SSL/HTTPS forced

- [x] **Database Configuration**
  - [x] `config/database.yml` production configuration
  - [x] Multiple database support (primary, cache, queue, cable)
  - [x] DATABASE_URL environment variable pattern configured

- [x] **File Storage Configuration**
  - [x] `config/storage.yml` Tigris service configured
  - [x] aws-sdk-s3 gem installed
  - [x] Active Storage service set to `:tigris`

### 2. Fly.io Configuration Files

- [x] **fly.toml**
  - [x] App name: `wellness-connect`
  - [x] Primary region: `lhr` (London)
  - [x] Processes: `app` (Rails server) and `solidq` (background jobs)
  - [x] Health checks configured on `/up` endpoint
  - [x] Machine auto-start/auto-suspend configured
  - [x] Release command: `./bin/rails db:prepare`

- [x] **Dockerfile**
  - [x] Multi-stage build configured
  - [x] Ruby 3.4.3 base image
  - [x] PostgreSQL client installed
  - [x] jemalloc for memory optimization
  - [x] Non-root user (rails:1000)
  - [x] Asset precompilation
  - [x] Thruster HTTP server

### 3. Environment Variables & Secrets

**Required Secrets** (set via `fly secrets set`):

- [ ] `RAILS_MASTER_KEY` - Rails credentials encryption key
  ```bash
  fly secrets set RAILS_MASTER_KEY="$(cat config/master.key)" --app wellness-connect
  ```

- [ ] `DATABASE_URL` - Automatically set by Fly.io when creating PostgreSQL cluster
  ```bash
  # Created automatically via: fly postgres create
  ```

- [ ] Tigris Storage Secrets (see FLYIO_TIGRIS_SETUP.md):
  - [ ] `AWS_ACCESS_KEY_ID`
  - [ ] `AWS_SECRET_ACCESS_KEY`
  - [ ] `AWS_ENDPOINT_URL_S3`
  - [ ] `BUCKET_NAME`

**Optional Secrets** (future enhancements):

- [ ] `STRIPE_PUBLISHABLE_KEY` - Stripe public key (when payment integration is enabled)
- [ ] `STRIPE_SECRET_KEY` - Stripe secret key
- [ ] `STRIPE_WEBHOOK_SECRET` - Stripe webhook signing secret
- [ ] `SMTP_ADDRESS` - Email server (when email is enabled)
- [ ] `SMTP_USERNAME` - Email username
- [ ] `SMTP_PASSWORD` - Email password

### 4. Fly.io Infrastructure Setup

- [ ] **Create Fly.io App**
  ```bash
  fly launch --name wellness-connect --region lhr --no-deploy
  ```

- [ ] **Create PostgreSQL Cluster**
  ```bash
  fly postgres create --name wellness-connect-db --region lhr --vm-size shared-cpu-1x --volume-size 10
  fly postgres attach wellness-connect-db --app wellness-connect
  ```

- [ ] **Create Tigris Storage Bucket**
  ```bash
  fly storage create --name wellness-connect-storage --org personal --app wellness-connect
  ```
  See `docs/FLYIO_TIGRIS_SETUP.md` for detailed instructions.

- [ ] **Set Secrets**
  ```bash
  fly secrets set RAILS_MASTER_KEY="$(cat config/master.key)" --app wellness-connect
  # Tigris secrets are set automatically by `fly storage create`
  ```

### 5. Database Setup

- [ ] **Verify Database Connection**
  ```bash
  fly ssh console --app wellness-connect
  # Inside SSH session:
  /rails/bin/rails db:version
  ```

- [ ] **Run Database Migrations**
  Migrations run automatically via release command in `fly.toml`:
  ```toml
  [deploy]
    release_command = './bin/rails db:prepare'
  ```

- [ ] **Verify Multiple Databases**
  ```bash
  fly ssh console --app wellness-connect
  /rails/bin/rails runner "puts ActiveRecord::Base.configurations.configs_for(env_name: 'production').map(&:name)"
  # Should output: primary, cache, queue, cable
  ```

### 6. Testing Before Deployment

- [x] **Local Tests**
  - [x] All tests passing: `bin/rails test`
  - [x] Linting passing: `bin/rubocop`
  - [x] Security scan: `bin/brakeman`

- [ ] **Production Simulation**
  ```bash
  # Build Docker image locally
  docker build -t wellness-connect:test .

  # Run container locally
  docker run -p 8080:8080 -e RAILS_ENV=production \
    -e SECRET_KEY_BASE=test \
    -e DATABASE_URL=postgresql://localhost/wellness_connect_production \
    wellness-connect:test
  ```

### 7. Deployment Steps

- [ ] **Initial Deployment**
  ```bash
  # Deploy application
  fly deploy --app wellness-connect

  # Monitor deployment
  fly logs --app wellness-connect

  # Check status
  fly status --app wellness-connect
  ```

- [ ] **Verify Health Checks**
  ```bash
  # Should show healthy status
  fly status --app wellness-connect

  # Test health endpoint directly
  curl https://wellness-connect.fly.dev/up
  ```

- [ ] **Verify Application**
  ```bash
  # Open application in browser
  fly open --app wellness-connect

  # Check logs for errors
  fly logs --app wellness-connect
  ```

### 8. Post-Deployment Verification

- [ ] **Basic Functionality**
  - [ ] Homepage loads correctly
  - [ ] User registration works
  - [ ] User login works
  - [ ] Provider profile creation works
  - [ ] Service creation works
  - [ ] Availability creation works
  - [ ] Appointment booking works

- [ ] **File Upload (Active Storage + Tigris)**
  - [ ] Provider can upload profile photo
  - [ ] Provider can upload credentials
  - [ ] Files are stored in Tigris
  - [ ] File URLs are accessible
  - [ ] File downloads work

- [ ] **Background Jobs (Solid Queue)**
  - [ ] Background jobs are running
  - [ ] Check Solid Queue dashboard (if enabled)
  - [ ] Verify job processing in logs

- [ ] **WebSockets (Solid Cable)**
  - [ ] Real-time features work (if implemented)
  - [ ] WebSocket connections established

- [ ] **Database**
  - [ ] All four databases are accessible
  - [ ] Migrations completed successfully
  - [ ] Data persists correctly

### 9. Monitoring & Observability

- [ ] **Set Up Monitoring**
  ```bash
  # Monitor application metrics
  fly dashboard --app wellness-connect

  # Monitor logs in real-time
  fly logs --app wellness-connect -f
  ```

- [ ] **Set Up Alerts** (via Fly.io dashboard)
  - [ ] Health check failures
  - [ ] High memory usage
  - [ ] High CPU usage
  - [ ] Application errors

- [ ] **Performance Monitoring**
  - [ ] Response times acceptable (<200ms)
  - [ ] Memory usage stable
  - [ ] No memory leaks

### 10. Security Verification

- [ ] **SSL/HTTPS**
  - [ ] Application forces HTTPS
  - [ ] SSL certificate valid
  - [ ] HSTS headers present

- [ ] **Content Security Policy**
  - [ ] CSP headers present
  - [ ] No CSP violations in browser console

- [ ] **Environment Variables**
  - [ ] No secrets in code
  - [ ] All secrets stored in Fly.io secrets
  - [ ] Credentials not logged

- [ ] **Database Security**
  - [ ] Database not publicly accessible
  - [ ] Strong database passwords
  - [ ] SSL connections to database

### 11. Backup & Disaster Recovery

- [ ] **Database Backups**
  - [ ] Verify Fly.io PostgreSQL automatic backups enabled
  - [ ] Test backup restoration process
  - [ ] Document backup retention policy

- [ ] **File Storage Backups**
  - [ ] Enable Tigris bucket versioning
  - [ ] Document file backup strategy
  - [ ] Test file restoration process

### 12. Documentation

- [ ] **Update Documentation**
  - [x] FLYIO_TIGRIS_SETUP.md created
  - [x] DEPLOYMENT_CHECKLIST.md created
  - [ ] README.md updated with deployment instructions
  - [ ] CLAUDE.md updated with production configuration

- [ ] **Runbook**
  - [ ] Document common operations
  - [ ] Document troubleshooting steps
  - [ ] Document rollback procedures

## Deployment Commands Reference

### Deploy Application
```bash
fly deploy --app wellness-connect
```

### View Logs
```bash
fly logs --app wellness-connect -f
```

### SSH into Application
```bash
fly ssh console --app wellness-connect
```

### Rails Console
```bash
fly ssh console --app wellness-connect
/rails/bin/rails console
```

### Database Console
```bash
fly postgres connect -a wellness-connect-db
```

### Scale Application
```bash
# Vertical scaling (more memory/CPU)
fly scale vm shared-cpu-2x --memory 2048 --app wellness-connect

# Horizontal scaling (more machines)
fly scale count 2 --app wellness-connect
```

### Rollback Deployment
```bash
# List recent deployments
fly releases --app wellness-connect

# Rollback to previous version
fly releases rollback --app wellness-connect
```

## Troubleshooting

### Issue: Health checks failing

**Check logs:**
```bash
fly logs --app wellness-connect
```

**Verify `/up` endpoint:**
```bash
fly ssh console --app wellness-connect
curl http://localhost:8080/up
```

### Issue: Database connection errors

**Check database status:**
```bash
fly postgres status -a wellness-connect-db
```

**Verify DATABASE_URL is set:**
```bash
fly secrets list --app wellness-connect | grep DATABASE_URL
```

### Issue: File upload failures

**Check Tigris configuration:**
```bash
fly secrets list --app wellness-connect | grep AWS
```

**Test Tigris connection from Rails console:**
```ruby
ActiveStorage::Blob.service.upload("test", StringIO.new("test content"))
```

### Issue: Background jobs not running

**Check Solid Queue process:**
```bash
fly logs --app wellness-connect | grep solidq
```

**Verify process is defined in fly.toml:**
```bash
fly ssh console --app wellness-connect
ps aux | grep solid_queue
```

## Post-Launch Checklist

After successful deployment:

- [ ] Update DNS (if using custom domain)
- [ ] Configure CDN (if needed)
- [ ] Set up monitoring and alerting
- [ ] Enable automated backups
- [ ] Configure log aggregation (optional)
- [ ] Set up error tracking (Sentry, Rollbar, etc.)
- [ ] Configure performance monitoring (New Relic, Scout, etc.)
- [ ] Update team documentation
- [ ] Communicate launch to stakeholders

## Maintenance Schedule

- **Daily**: Monitor logs and health checks
- **Weekly**: Review performance metrics and errors
- **Monthly**: Security updates and dependency updates
- **Quarterly**: Disaster recovery testing
- **Annually**: Security audit and penetration testing

## Resources

- [Fly.io Documentation](https://fly.io/docs/)
- [Fly.io Rails Guide](https://fly.io/docs/rails/)
- [Fly.io Tigris Documentation](https://fly.io/docs/reference/tigris/)
- [Rails Deployment Guide](https://guides.rubyonrails.org/deployment.html)
