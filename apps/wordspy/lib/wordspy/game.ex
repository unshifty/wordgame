defmodule Wordspy.Game do
  defstruct [:name, :wordlib, :words, :tiles, :turn, :winner, :score]

  alias Wordspy.{Game, Tile}

  def new(name, wordlib, score \\ %{red: 0, blue: 0}) do
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
      winner: nil,
      score: score
    }
  end

  def reveal(game, word) do
    # gets the tile keyed by 'word'
    tile = Tile.reveal(game.tiles[word], game.turn)

    # check win conditions
    # if team has no remaining tiles, they win
    # if team revealed the assassin they lose
    winner =
      cond do
        hidden_tiles(game, game.turn) == 0 -> {game.turn, :success}
        tile.team == :assassin -> {not_team(game.turn), :assassin}
        true -> nil
      end

    score =
      if winner do
        %{game.score | elem(winner, 0) => game.score[elem(winner, 0)] + 1}
      else
        game.score
      end

    # if revealed tile was not the team's end the turn
    turn =
      cond do
        tile.team == game.turn -> game.turn
        true -> not_team(game.turn)
      end

    %Game{
      game
      | tiles: Map.put(game.tiles, word, tile),
        turn: turn,
        winner: winner,
        score: score
    }
  end

  def end_turn(game) do
    %Game{game | turn: not_team(game.turn)}
  end

  def total_tiles(game, team) do
    game.tiles
    |> Enum.filter(fn {_, t} -> t.team == team end)
    |> Enum.count()
  end

  def revealed_tiles(game, team) do
    game.tiles
    |> Enum.filter(fn {_, t} -> t.team == team and t.visibility == :revealed end)
    |> Enum.count()
  end

  def hidden_tiles(game, team) do
    game.tiles
    |> Enum.filter(fn {_, t} -> t.team == team and t.visibility == :hidden end)
    |> Enum.count()
  end

  def is_hidden(game, word) do
    game.tiles[word].visibility == :hidden
  end

  defp make_tiles(words, team) do
    words
    |> Enum.map(fn word -> {word, Tile.new(word, team)} end)
  end

  defp not_team(:red), do: :blue
  defp not_team(:blue), do: :red
end
