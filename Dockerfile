FROM ruby:3.0.1

RUN gem install bundler:2.4.13

# Add NodeSource apt repository
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -

# Add Yarn apt repository
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client yarn

RUN mkdir /blogs_app
WORKDIR /blogs_app

# Add Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Set bundler config
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle config build.sqlite3 --use-system-libraries
RUN bundle config set force_ruby_platform true

RUN bundle install

COPY . /blogs_app

# Add entrypoint script and set permissions
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Start server
CMD ["rails", "server", "-b", "0.0.0.0"]
