Rails.application.config.middleware.use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_SECRET_KEY']
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}