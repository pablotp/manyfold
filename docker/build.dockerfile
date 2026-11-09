## BUILD STAGE ##########################################

FROM base AS build-tools

RUN apk add --no-cache \
  alpine-sdk \
  gcompat \
  bzip2 \
  gmp-dev \
  libffi-dev \
  procps \
  yaml-dev \
  zlib-dev \
  nodejs=~24.22.1 \
  npm \
  postgresql-dev \
  mariadb-dev \
  libarchive

# JavaScript and Ruby dependencies are installed in separate stages so that they
# are cached independently (a package.json change does not reinstall every gem,
# and vice versa) and so that BuildKit installs both in parallel.
FROM build-tools AS node-deps
COPY package.json .
COPY yarn.lock .
RUN npm install --global corepack
RUN corepack enable yarn
RUN yarn install

FROM build-tools AS gem-deps
COPY .ruby-version .
COPY Gemfile* ./
RUN bundle install

FROM node-deps AS build
COPY --from=gem-deps /usr/src/app/vendor/bundle vendor/bundle

COPY . .
RUN touch db/schema.rb
RUN \
  DATABASE_URL="nulldb://user:pass@localhost/db" \
  SECRET_KEY_BASE="placeholder" \
  RACK_ENV="production" \
  RAILS_ASSETS_PRECOMPILE=1 \
  bundle exec rake assets:precompile
RUN rm db/schema.rb
