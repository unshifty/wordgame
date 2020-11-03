defmodule WordplayWeb.GameBoardLive do
  use Phoenix.LiveComponent

  alias Wordspy.Game

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="mx-auto grid grid-cols-4 lg:grid-cols-6 gap-1 sm:gap-2">
      <%= for word <- @game.words do %>
        <button phx-click="<%= on_click_event(assigns, word) %>" phx-value-word="<%= word %>" class="font-semibold focus:outline-none">
          <div class="<%= tile_classes(@game.tiles[word], assigns) <> ~s( h-12 sm:h-20 md:h-24 flex flex-col justify-center text-xs sm:text-base md:text-lg rounded-lg) %>">
            <p class="text-center break-words"><span class="<%= word_classes(@game.tiles[word], assigns) <> ~s( )%>"><%= word %></span>
          </div>
        </button>
      <% end %>
    </div>
    """
  end

  def on_click_event(assigns, word) do
    # only enable reveal if hidden and not spymaster
    if Game.is_hidden(assigns.game, word) and not assigns.is_spymaster and
         assigns.game.turn == assigns.team do
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

  # def tile_classes(_tile, %{is_spymaster: true}) do
  def tile_classes(_tile, %{is_spymaster: is_spymaster, game: %Game{winner: winner}})
    when (is_spymaster or winner != nil) do
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

  def word_classes(tile, %{is_spymaster: is_spymaster, game: %Game{winner: winner}})
  when (is_spymaster or winner != nil) do
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

  def word_classes(_tile, _assigns) do
    ""
  end
end
