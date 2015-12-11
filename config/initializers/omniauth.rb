OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '577879082164-1532dp46j664d7u78ovqi650k92iv42r.apps.googleusercontent.com', 'SGZfMuiRdu3G9Z38t692XkOX', {skip_jwt: true, :scope => "email, profile, plus.me, https://www.googleapis.com/auth/drive, calendar", client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}

  on_failure do |env|
    WelcomeController.action(:index).call(env)
  end
end

