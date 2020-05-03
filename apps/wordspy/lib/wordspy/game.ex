defmodule Wordspy.Game do
  defstruct [:name, :wordlib, :words, :tiles, :turn, :winner, :remaining_tiles]

  alias Wordspy.{Game, Tile}

  def new(name, wordlib) do
    [team1, team2] = Enum.shuffle([:blue, :red])
    words = Wordspy.WordCache.get_wordset(wordlib, 24)

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
      remaining_tiles: %{team1 => 9, team2 => 8, :bystander => 6, :assassin => 1},
      winner: nil
    }
  end

  def reveal(game, word, team) do
    # gets the tile keyed by 'word'
    new_tile = Tile.reveal(game.tiles[word], team)
    # if the tile revealed the team's word, decrement the tiles remaining
    new_remaining_tiles = update_in(game.remaining_tiles, [new_tile.team], &(&1 - 1))

    # check win conditions
    # if team has no remaining tiles, they win
    # if team revealed the assassin they lose
    new_winner =
      cond do
        new_remaining_tiles[team] == 0 -> {team, :success}
        new_tile.team == :assassin -> {not_team(team), :assassin}
        true -> nil
      end

    %Game{
      game
      | tiles: Map.put(game.tiles, word, new_tile),
        remaining_tiles: new_remaining_tiles,
        winner: new_winner
    }
  end

  def end_turn(game) do
    %Game{game | turn: not_team(game.turn)}
  end

  defp make_tiles(words, team) do
    words
    |> Enum.map(fn word -> {word, Tile.new(word, team)} end)
  end

  defp not_team(team) do
    if team == :red, do: :blue, else: :red
  end
end
