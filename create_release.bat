REM https://hexdocs.pm/phoenix/releases.html

call mix deps.get --only prod
set MIX_ENV=prod
call mix compile
call mix assets.deploy
call mix phx.gen.release
call mix release --overwrite