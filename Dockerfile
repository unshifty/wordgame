FROM elixir:1.9-alpine as build

# install build dependencies
RUN apk add --update git build-base nodejs npm yarn python

RUN mkdir /app
WORKDIR /app

# install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

COPY config/ /app/config/
# COPY mix.exs /app/
COPY mix.* /app/

COPY apps/wordplay/mix.exs /app/apps/wordplay/
# COPY apps/wordspy/mix.exs /app/apps/wordspy/
COPY apps/wordspy/ /app/apps/wordspy/

# set build ENV
ENV MIX_ENV=prod
RUN mix do deps.get --only $MIX_ENV, deps.compile

COPY . /app/

RUN ls -la /app/apps/wordspy/*

# switch to wordplay to build assets
WORKDIR /app/apps/wordplay
RUN MIX_ENV=prod mix compile
RUN npm ci --prefix ./assets
RUN npm run deploy --prefix ./assets
RUN mix phx.digest

WORKDIR /app
RUN MIX_ENV=prod mix release

# install mix dependencies
# COPY mix.exs mix.lock ./
# COPY config config
# RUN mix do deps.get --only $MIX_ENV, deps.compile

# build assets
# COPY assets/package.json assets/package-lock.json ./assets/
# COPY apps/wordplay/priv apps/wordplay/priv
# COPY apps/wordplay/assets apps/wordplay/assets

# RUN npm ci --prefix ./apps/wordplay/assets
# RUN npm run deploy --prefix ./apps/wordplay/assets
# RUN cd apps/wordplay/assets \
# && npm ci \
# && npm run deploy \
# && cd ../../..

# RUN mix phx.digest

# build project
# COPY lib lib
# RUN mix compile

# build release
# at this point we should copy the rel directory but
# we are not using it so we can omit it
# COPY rel rel
# RUN mix release

########################################################################

# prepare release image
FROM alpine:3.9 AS app

# install runtime dependencies
RUN apk add --update bash openssl

EXPOSE 4000
ENV MIX_ENV=prod

# prepare app directory
RUN mkdir /app
WORKDIR /app

# copy release to app container
COPY --from=build app/_build/prod/rel/wordgames .
# COPY --from=build app/bin/ ./bin
COPY entrypoint.sh .
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
CMD ["bash", "/app/entrypoint.sh"]