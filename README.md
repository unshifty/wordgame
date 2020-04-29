# Wordgame

To start your Phoenix server:

  * Setup the project with `mix setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Dokku config

References
  * https://medium.com/@jonlunsford/elixir-up-and-running-with-dokku-on-digital-ocean-ce332d64224c
  * https://dev.to/mplatts/deploying-phoenix-via-dokku-1gip

* Config the Endpoint
  * In prod.exs
    ```
    http: [:inet6, port: System.get_env("PORT")],
    url: [host: System.get_env("WEB_HOST"), port: 80],
    ```
* Create Procfile in root
  ```web: ./.platform_tools/elixir/bin/mix phx.server```
* Create .buildpacks in root
```
  https://github.com/hashnuke/heroku-buildpack-elixir
  https://github.com/gjaldon/heroku-buildpack-phoenix-static
```
* Create .elixir_buildpack.config in root
  * Set to latest versions unless there's a good reason not to
```
  elixir_version=1.10.3
  erlang_version=21.1.1
```
* Add a remote to the git repo *called dokku*
```git remote add dokku dokku@159.65.164.216:wordgame```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
