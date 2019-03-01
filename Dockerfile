FROM ruby:alpine
WORKDIR /opt/tiny-rhsso-oauth-app

RUN adduser -D tiny-rhsso-oauth-app

COPY Gemfile Gemfile.lock ./

RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  tzdata \
  ca-certificates \
  && rm -rf /var/cache/apk/*

RUN gem install bundler && \
  bundle config build.nokogiri --use-system-libraries && \
  bundle install --without "test development"

ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=present
# remove line above to disable that behavior

USER tiny-rhsso-oauth-app
CMD ["ruby", "server.rb"]

EXPOSE 4567
