defmodule WordplayWeb.WordspyView do
  use WordplayWeb, :view

  alias Wordspy.Game

  def game_count() do
    Wordspy.GameSupervisor.game_names |> Enum.count()
  end


  def on_click_event(assigns, word) do
    # only enable reveal if hidden and not spymaster
    if Game.is_hidden(assigns.game, word) and not assigns.is_spymaster and assigns.game.turn == assigns.team do
      "reveal"
    else
      ""
    end
  end

  def tile_classes(%{visibility: :revealed} = tile, _assigns) do
    cond do
      tile.team == :red ->
        "bg-red-600 text-white shadow-inner cursor-default"

      tile.team == :blue ->
        "bg-blue-600 text-white shadow-inner cursor-default"

      tile.team == :bystander ->
        "bg-gray-500 text-black cursor-default"

      tile.team == :assassin ->
        "bg-black text-white cursor-default"
    end
  end

  def tile_classes(_tile, %{is_spymaster: true}) do
    "bg-gray-300 text-black border border-gray-400 cursor-default"
  end

  def tile_classes(_tile, %{game: game, team: user_team}) do
    if game.turn == user_team do
      "bg-gray-300 text-black border border-gray-400 hover:shadow-md"
    else
      "bg-gray-300 text-black border border-gray-400 cursor-default"
    end
  end

  def word_classes(%{visibility: :revealed}, _assigns) do
    ""
  end
  def word_classes(_tile, %{is_spymaster: false}) do
    ""
  end
  def word_classes(tile, _is_spymaster) do
    cond do
      tile.team == :red ->
        "border-b-4 border-red-600 text-red-600"

      tile.team == :blue ->
        "border-b-4 border-blue-600 text-blue-600"

      tile.team == :bystander ->
        "border-b-4 border-gray-700 text-gray-700"

      tile.team == :assassin ->
        "p-1 bg-black text-white rounded-lg"
    end
  end
end
