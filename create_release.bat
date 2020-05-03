set MIX_ENV=prod

call mix deps.get --only prod
call mix compile

cd ./assets
call npm install
call npm run deploy
cd ..

call mix phx.digest

call mix release --overwrite