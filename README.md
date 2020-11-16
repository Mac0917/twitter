## 概要
twitter apiを使った練習用のアプリです。

## バージョン
ruby・・・2.5.7<br>
rails・・・5.2.4.4<br>
mysql・・・5.7

## ローカル環境での実行手順
dockerとdocker-composeを自分のpcにインストール

好きなディレクトリで<br>
`git clone https://github.com/Mac0917/twitter.git`

移動<br>
`cd twitter`

docker-composeを実行<br>
`docker-compose up -d`

データベース作成<br>
`docker exec -it twitter_app_1 bash`(コンテナに入る)<br>
`rails db:create`<br>
`rails db:migrate`<br>

アクセス<br>
http://localhost/<br>
twitter APIを取得してないのでエラーがでます。下の見出しを読んで実装してみてください。

終了<br>
`exit`(コンテナから出る)<br>
`docker-compose stop`<br>
`docker-compose rm`<br>
`docker rmi twitter_app twitter_web`<br>
`docker volume rm twitter_db-data twitter_public-data twitter_tmp-data`

リポジトリを削除<br>
`cd ..`<br>
`rm -rf twitter`


## twitter認証のやり方
 参考・・・https://ikatde.com/ruby-on-rails-twitter-omniauth/

### 1  twitterのapiキーを取得 
  https://developer.twitter.com/ja <br>
  より自分のアプリを制作してapiキーをゲット
  自分のtwitterでメールアドレスを登録しないと弾かれる可能性あり

### 2 twitterのapiキーの認証設定 すごく大事
　callbackurlのみ設定しておく<br>
　このように書く<br>
  ``
  http://localhost:3000/auth/twitter/callback 
  ``
  <アプリのURL>/auth/twitter/callback  
  一つだけ設定していればいい

### 3 rails を記述
  `
  gem 'dotenv-rails'
  bundle install
  `
  <br>
  .envをtouchで作る<br>
  .envファイルに
  ```
    TWITTER_CONSUMER_KEY='ここに API key を記述'
    TWITTER_SECRET_KEY='ここに API secret key を記述'
  ```
  igonreに.envを記述

  ```
  gem 'omniauth-twitter'
  gem "omniauth-rails_csrf_protection"
  bundle install
  ```
  
  「omniauth.rb」というファイルを「config/initializers」のディレクトリに作成
  そこに
  ```
    Rails.application.config.middleware.use OmniAuth::Builder do
        provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_SECRET_KEY']
    end
  ```
  ```
　rails g model User provider:string uid:string nickname:string name:string          image_url:string description:string
  ```

```
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
```

```
rails g controller Sessions
```

```
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
```

```
 rails g controller Homes
```

```
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
```

```
<%= link_to "login" ,"/auth/twitter", method: :post %> これは自分のアプリではなくtwitterの認証画面にいく
```


ルーティング
```
Rails.application.routes.draw do
  root 'homes#index'
  get '/homes', to: 'homes#index'
  ## コールバックurlを http://localhost:3000/auth/twitter/callback と設定しているので認証が終わったらこのurlに飛ぶ
  get '/auth/:provider/callback', to: 'sessions#create' 
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'homes#login'
end
```

コールバックした後は
`
request.env['omniauth.auth']
`
これでデータを取得できる

### userが認証を拒否したとき
 omniauth.rbで
```
 OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
```
を記述するとコールバックが<br>
 [GET] "/auth/failure"になる