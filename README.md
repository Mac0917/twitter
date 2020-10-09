### twitter認証のやり方
 参考https://ikatde.com/ruby-on-rails-twitter-omniauth/

# 1  twitterのapiキーを取得 
  https://developer.twitter.com/jaで自分のアプリを制作してapiキーをゲット
  自分のtwitterでメールアドレスを登録しないと弾かれる可能性あり

# 2 twitterのapiキーの認証設定 大事
　callbackurlのみ設定しておく
  http://localhost:3000/auth/twitter/callback  このように書く
  <アプリのURL>/auth/twitter/callback  
  一つだけ設定していればいい
  これは設定のtwitterのダッシュボードのurl
  https://developer.twitter.com/en/portal/projects/1294832087715864576/apps/18622424/auth-settings

# 3 rails を書く
  gem 'dotenv-rails'
  bundle install
  .envをtouchで作る
  .envファイルに
    TWITTER_CONSUMER_KEY='ここに API key を記述'
    TWITTER_SECRET_KEY='ここに API secret key を記述'
  igonreに.envを記述

  gem 'omniauth-twitter'
  gem "omniauth-rails_csrf_protection"
  bundle install

  「omniauth.rb」というファイルを「config/initializers」のディレクトリに作成
  そこに
    Rails.application.config.middleware.use OmniAuth::Builder do
        provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_SECRET_KEY']
    end

　rails g model User provider:string uid:string nickname:string name:string          image_url:string description:string

class User < ApplicationRecord
  def self.find_or_create_from_auth(auth)
    provider = auth[:provider]
    uid = auth[:uid]
    nickname = auth[:info][:nickname]
    name = auth[:info][:name]
    image_url = auth[:info][:image]
    description = auth[:info][:description]
    
    self.find_or_create_by(provider: provider, uid: uid) do |user|
      user.nickname = nickname
      user.name = name
      user.image_url = image_url
      user.description = description
    end
  end
end


rails g controller Sessions

class SessionsController < ApplicationController

  def create
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end  
  
end

 rails g controller Homes

 class HomesController < ApplicationController
  def index
    if session[:user_id].nil?
      redirect_to action:'login'
    else
      @user = User.find(session[:user_id])
    end
  end
  
  def login
  end
end


<%= link_to "login" ,"/auth/twitter", method: :post %> これは自分のアプリではなくtwitterの認証画面にいく



ルーティング
Rails.application.routes.draw do
  root 'homes#index'
  get '/homes', to: 'homes#index'
  ## コールバックurlを http://localhost:3000/auth/twitter/callback と設定しているので認証が終わったらこのurlに飛ぶ
  get '/auth/:provider/callback', to: 'sessions#create' 
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'homes#login'
end


### userが認証を拒否したとき
 omniauth.rbで
 OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
を記述するとコールバックが
 [GET] "/auth/failure"になる