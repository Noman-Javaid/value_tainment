FROM ruby:3.0.1-alpine3.13
ARG BUNDLE_WITHOUT
ARG RAILS_ENV
ARG RAILS_MASTER_KEY
LABEL Author="Ever Acosta <ever.acosta@koombea.com>"
ENV RAILS_LOG_TO_STDOUT="enabled" \
    RAILS_SERVE_STATIC_FILES="enabled" \
    BUNDLE_WITHOUT=${BUNDLE_WITHOUT:-"development test"} \
    RAILS_ENV=${RAILS_ENV} \
    APP_DIR="/usr/src/app/" \
    TMP_PACKAGES="build-base git libxml2-dev libxslt-dev" \
    RUNTIME_PACKAGES="aws-cli bash findutils groff less python3 tini inotify-tools py-pip vips postgresql-dev xz-dev tzdata nodejs openssl yarn curl jq imagemagick" \
    SECRET_KEY_BASE="5570b2599d6d10fe0ea7b515fe0636991a787ed864d2f4be164a638c67015691d38fd19e2a6c33d5dd99e0abd97df079eb79699e895df717e5782948cfee9fe13e420108ae1bb9dc0fa1801b9976a4c5efb703c713b89f34eea7090389b60f11442556b71121ab4cd8f3f9760d6936edcfb8fb48dd7cdfe9fabfde1ad822c1e8" \
    RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
    DATABASE_URL="postgres://postgres:mysecretpassword@db:5432/test" 
#    RUN_TEST="enabled"
WORKDIR $APP_DIR
RUN apk add --no-cache --virtual .tmp_packages $TMP_PACKAGES && \
    apk add --no-cache --virtual .runtime_packages $RUNTIME_PACKAGES
COPY Gemfile* $APP_DIR
RUN gem install bundler -v "2.2.17" && \
    bundle config set without $BUNDLE_WITHOUT && \
    bundle install --jobs 4 --retry 5
COPY . $APP_DIR
RUN apk del .tmp_packages
RUN bundle exec rails assets:precompile
ENTRYPOINT ["sh", "./docker-entrypoint.sh"]
