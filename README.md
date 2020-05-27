# Overview
This is an online version of the [Codenames](https://en.wikipedia.org/wiki/Codenames_(board_game)) board game.
It's meant for two teams, with at least 2 players on each team. Right now it's a party style game, so everyone needs to be able to talk, e.g. over video chat (or in person one day).

# Architecture
The game is implemented in Elixir, using the Phoenix web framework, and Phoenix LiveView for updating the game board.
There are two projects, in an umbrella configuration.
  * apps/wordspy is the game itself
  * apps/wordplay is the web client
  
## Wordspy
The wordspy project contains the functionality for running multiple games
* GameSupervisor is the top level supervisor that manages all game servers
* GameServer manages the state for an individual game and is implemented as a GenServer
  * GameServer's stay alive for one hour after the last update.
    * On each update to the game state, the timeout resets.
* The Game module contains the functions for manipulating a Game struct, which houses the actual data for a game
* GameSupervisor
  * GameServer > Game
  * GameServer > Game
  * ...
  
## Wordplay
The wordplay project is a Phoenix app that implements the web client.
* Standard Phoenix app setup with
  * --no-ecto because no database is used
  * --liveview for updating the game board when the game state changes
* 

# Building and Deploying

* If changing domain for deployment update new domains in
  * config/prod.exs
  * apps/wordplay/lib/wordplay_web/Endpoint.ex

## Publishing Docker Image

* Edit docker.bat with new version
* Run ```docker.bat build`` to build the image
* Run ```docker.bat push``` to publish
* sign in to host
  * edit docker-compose.yml and update image version
    * image: "docker.pkg.github.com/okadoke/wordgame/wordgames:<NEW_VERSION>"
  * docker-compose down
  * docker-compose up -d

**TODO: Add description**

