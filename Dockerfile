FROM ruby:3.0.1

RUN gem install bundler:2.4.13

RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client yarn
RUN mkdir /blogs_app
WORKDIR /blogs_app

# 追加
COPY Gemfile Gemfile.lock ./

# 新たに追加
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle config build.sqlite3 --use-system-libraries
RUN bundle config set force_ruby_platform true

RUN bundle install
COPY . /blogs_app

# コンテナ起動時に毎回実行する
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# rails s　実行.
CMD ["rails", "server", "-b", "0.0.0.0"]
