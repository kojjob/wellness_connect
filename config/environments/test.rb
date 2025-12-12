# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

require "digest"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # Active Record Encryption
  # CI/test does not load production credentials (no RAILS_MASTER_KEY), but
  # Rails may still require encryption keys when interacting with encrypted
  # attributes (including framework tables like Active Storage in newer Rails).
  # IMPORTANT: system tests boot the app server separately from the test process.
  # If we generate random keys per boot, records encrypted in one process can't
  # be decrypted in the other.
  # IMPORTANT: keep this stable across processes AND across runs. Some CI
  # environments (and local setups without credentials) may generate
  # `secret_key_base` dynamically, which would make encryption keys drift and
  # break decrypting records created earlier in the run.
  test_key_base = ENV["ACTIVE_RECORD_ENCRYPTION_TEST_KEY_BASE"].presence ||
    "wellness_connect-test-encryption-key-base"

  config.active_record.encryption.key_derivation_salt ||= Digest::SHA256.hexdigest("#{test_key_base}-salt")

  # Don't call ActiveRecord::Encryption.key_generator here: it depends on the
  # encryption config being fully initialized (including the salt), and system
  # tests boot the app multiple times.
  config.active_record.encryption.primary_key ||= Digest::SHA256.digest("#{test_key_base}-primary")
  config.active_record.encryption.deterministic_key ||= Digest::SHA256.digest("#{test_key_base}-deterministic")

  # Fixtures insert raw values directly into the DB (bypassing model encryption).
  # Allow reading those plaintext values in tests.
  config.active_record.encryption.support_unencrypted_data = true
end
