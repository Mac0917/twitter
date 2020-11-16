FROM ruby:2.5.7

RUN apt-get update -qq && apt-get install -y build-essential nodejs vim

RUN mkdir /twitter
WORKDIR /twitter

# ホストのGemfileとGemfile.lockをコンテナにコピー
COPY Gemfile /twitter/Gemfile
COPY Gemfile.lock /twitter/Gemfile.lock

# bundle installの実行
RUN bundle install

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
COPY . /twitter

# puma.sockを配置するディレクトリを作成
RUN mkdir tmp/sockets