Rails.application.configure do
  config.action_controller.perform_caching = true
  config.action_controller.include_all_helpers = true
  config.active_support.deprecation = :log

  config.action_mailer.default_url_options = { host: Rails.application.secrets.full_domain_name }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address:  Rails.application.secrets.localhost,
    port:     Rails.application.secrets.mailcatcher_port,
    domain:   Rails.application.secrets.domain_name
  }
  config.action_mailer.asset_host = Rails.application.secrets.full_domain_name

  config.sass.cache = true
  config.assets.digest = true
  config.assets.debug = true
  config.assets.raise_runtime_errors = true

  config.cache_classes = false
  config.consider_all_requests_local = true
  config.eager_load = true

  config.web_console.whiny_requests = false
  config.web_console.whitelisted_ips = Rails.application.secrets.web_console_whitelisted_ips
  config.web_console.template_paths = 'app/views/web_console'

  config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload
end

AnyLogin.setup do |config|
  config.provider = :devise
  config.enabled = true
  config.collection_method = :all
  config.redirect_path_after_login = :new_user_session_path
  config.login_on = :both
  config.limit = :none
end
