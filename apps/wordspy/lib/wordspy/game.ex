defmodule Wordspy.Game do
  defstruct [:name, :wordlib, :words, :tiles, :turn, :spymasters, :remaining_tiles, :winner]

  alias Wordspy.{Game, Tile}

  def new(name, wordlib) do
    [team1, team2] = Enum.shuffle([:blue, :red])
    words = Wordspy.WordCache.generate_wordset(wordlib, 24)

    tilemap =
      (make_tiles(Enum.slice(words, 0, 1), :assassin) ++
         make_tiles(Enum.slice(words, 1, 9), team1) ++
         make_tiles(Enum.slice(words, 10, 8), team2) ++
         make_tiles(Enum.slice(words, 18, 6), :bystander))
      |> Map.new()

    %Game{
      name: name,
      wordlib: wordlib,
      # shuffle the words so that the tile types aren't aligned
      words: Enum.shuffle(words),
      tiles: tilemap,
      turn: team1,
      spymasters: MapSet.new(),
      winner: nil
    }
  end

  def reveal(game, word, team) do
    # gets the tile keyed by 'word'
    tile = Tile.reveal(game.tiles[word], team)

    # check win conditions
    # if team has no remaining tiles, they win
    # if team revealed the assassin they lose
    new_winner =
      cond do
        hidden_tiles(game, team) == 0 -> {team, :success}
        tile.team == :assassin -> {not_team(team), :assassin}
        true -> nil
      end

    # if revealed tile was not the team's end the turn
    turn = cond do
      tile.team == team   -> team
      true                -> not_team(team)
    end

    %Game{
      game
      | tiles: Map.put(game.tiles, word, tile),
        turn: turn,
        winner: new_winner
    }
  end

  def end_turn(game) do
    %Game{game | turn: not_team(game.turn)}
  end

  def total_tiles(game, team) do
    game.tiles
    |> Enum.filter(fn {_, t} -> t.team == team end)
    |> Enum.count
  end

  def revealed_tiles(game, team) do
    game.tiles
    |> Enum.filter(fn {_, t} -> t.team == team and t.visibility == :revealed end)
    |> Enum.count
  end

  def hidden_tiles(game, team) do
    game.tiles
    |> Enum.filter(fn {_, t} -> t.team == team and t.visibility == :hidden end)
    |> Enum.count
  end

  defp make_tiles(words, team) do
    words
    |> Enum.map(fn word -> {word, Tile.new(word, team)} end)
  end

  defp not_team(team) do
    if team == :red, do: :blue, else: :red
  end
end
