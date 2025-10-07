# Fly.io Tigris Storage Setup Guide

This guide explains how to set up Tigris (Fly.io's S3-compatible object storage) for Active Storage in production.

## Prerequisites

- Fly.io CLI installed and authenticated (`fly auth login`)
- Application deployed on Fly.io (`wellness-connect`)
- Ruby on Rails application with Active Storage configured

## Configuration Status

✅ **Already Configured:**
- `config/storage.yml` - Tigris service configuration (lines 29-35)
- `config/environments/production.rb` - Active Storage set to use `:tigris` (line 37)
- `Gemfile` - aws-sdk-s3 gem installed

## Setup Steps

### 1. Create Tigris Bucket

Run the following command to create a new Tigris bucket for your application:

```bash
fly storage create --name wellness-connect-storage --org personal --app wellness-connect
```

This will:
- Create a new Tigris bucket named `wellness-connect-storage`
- Automatically set the required environment variables in your Fly.io app:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_ENDPOINT_URL_S3`
  - `BUCKET_NAME`

**Note:** The bucket name must be globally unique. If `wellness-connect-storage` is taken, use a different name like `wellness-connect-storage-<your-org>` or `wellness-connect-prod-storage`.

### 2. Verify Environment Variables

Check that all required environment variables are set:

```bash
fly secrets list --app wellness-connect
```

You should see:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ENDPOINT_URL_S3`
- `BUCKET_NAME`
- `RAILS_MASTER_KEY` (should already exist)
- `DATABASE_URL` (should already exist)

### 3. Manual Secret Setup (if automatic setup fails)

If the automatic setup doesn't work or you need to set secrets manually:

```bash
# Set Tigris credentials (replace with actual values from Tigris console)
fly secrets set AWS_ACCESS_KEY_ID="your-access-key-id" --app wellness-connect
fly secrets set AWS_SECRET_ACCESS_KEY="your-secret-access-key" --app wellness-connect
fly secrets set AWS_ENDPOINT_URL_S3="https://fly.storage.tigris.dev" --app wellness-connect
fly secrets set BUCKET_NAME="wellness-connect-storage" --app wellness-connect
```

### 4. Test Storage Configuration

Deploy the application to test the storage configuration:

```bash
# Deploy the application
fly deploy --app wellness-connect

# Check application logs
fly logs --app wellness-connect
```

### 5. Verify Active Storage

After deployment, test file uploads:

1. Sign in to the application as a provider
2. Navigate to profile settings
3. Upload a profile photo or credential document
4. Verify the file is uploaded successfully
5. Check that the file URL points to Tigris (should include `fly.storage.tigris.dev`)

## Tigris Storage Configuration Details

### Storage Service Configuration (config/storage.yml)

```yaml
tigris:
  service: S3
  access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
  endpoint: <%= ENV["AWS_ENDPOINT_URL_S3"] %>
  bucket: <%= ENV["BUCKET_NAME"] %>
```

### Production Environment Configuration (config/environments/production.rb)

```ruby
config.active_storage.service = :tigris
```

## Storage Costs

- **Tigris Pricing**: Free tier includes 5 GB storage and 5 GB bandwidth per month
- **Paid tiers**: $0.02/GB/month for storage, $0.05/GB for bandwidth
- Monitor usage via Fly.io dashboard: https://fly.io/dashboard/personal/billing

## Troubleshooting

### Issue: "Access Denied" errors in logs

**Solution**: Verify AWS credentials are correct:
```bash
fly secrets list --app wellness-connect
```

Check that `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` match your Tigris bucket credentials.

### Issue: "Bucket not found" errors

**Solution**: Verify the bucket name:
```bash
fly storage list --app wellness-connect
```

Ensure `BUCKET_NAME` environment variable matches the actual bucket name.

### Issue: Files not uploading

**Solution**: Check Active Storage configuration:
1. Verify `config/environments/production.rb` has `config.active_storage.service = :tigris`
2. Check logs for error messages: `fly logs --app wellness-connect`
3. Verify CORS configuration if uploading from browser (Direct Upload)

### Issue: Slow file uploads/downloads

**Solution**: Tigris is a global CDN, but initial uploads may be slow. Consider:
- Enabling Direct Upload for large files
- Using background jobs for file processing
- Configuring CDN caching headers

## Security Best Practices

1. **Never commit credentials**: All credentials are environment variables, never in code
2. **Rotate credentials periodically**: Generate new access keys every 90 days
3. **Use HTTPS**: Tigris endpoint uses HTTPS by default
4. **Enable bucket versioning**: Protect against accidental deletions
5. **Set bucket policies**: Restrict public access if not needed

## Advanced Configuration

### Enable Direct Upload (Optional)

For large file uploads, enable Direct Upload to send files directly to Tigris from the browser:

```ruby
# config/environments/production.rb
config.active_storage.web_image_content_types = %w[image/png image/jpeg image/jpg image/gif]
config.active_storage.variant_processor = :vips
config.active_storage.draw_routes = true
```

Then in your views:
```erb
<%= form.file_field :avatar, direct_upload: true %>
```

### Configure CORS for Direct Upload

If using Direct Upload, configure CORS on your Tigris bucket:

```json
{
  "CORSRules": [
    {
      "AllowedOrigins": ["https://wellness-connect.fly.dev"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"],
      "MaxAgeSeconds": 3000
    }
  ]
}
```

## Monitoring

Monitor storage usage and costs:

```bash
# View storage metrics
fly storage show wellness-connect-storage --app wellness-connect

# View billing information
fly billing show
```

## Backup and Disaster Recovery

1. **Bucket Versioning**: Enable versioning to protect against accidental deletions
2. **Regular Backups**: Consider backing up critical files to a separate bucket
3. **Replication**: For high-availability, consider multi-region replication (enterprise feature)

## Resources

- [Fly.io Tigris Documentation](https://fly.io/docs/reference/tigris/)
- [Active Storage Guide](https://guides.rubyonrails.org/active_storage_overview.html)
- [AWS S3 Ruby SDK Documentation](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3.html)

## Next Steps

After setting up Tigris storage:

1. ✅ Test file uploads in production
2. ✅ Verify file URLs are correct
3. ✅ Monitor storage usage and costs
4. Configure image processing (if needed)
5. Set up automated backups (optional)
6. Configure CDN caching (optional)
7. Enable Direct Upload for large files (optional)
