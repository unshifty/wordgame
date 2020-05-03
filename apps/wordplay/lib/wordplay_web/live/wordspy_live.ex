defmodule WordplayWeb.WordspyLive do
  use WordplayWeb, :live_view

  @impl true
  def mount(%{"id" => name}, session, socket) do
    # subscribe to pubsub messages for this specific game
    Phoenix.PubSub.subscribe(Wordplay.PubSub, game_topic(name))
    game = Wordspy.GameServer.summary(name)
    socket = assign(socket, game: game)
    {:ok, socket}
  end

  @impl true
  def handle_event("reveal", %{"word" => word}, socket) do
    Phoenix.PubSub.broadcast_from(Wordplay.PubSub, self(), game_topic(socket.assigns.game.name), %{reveal: word})
    IO.puts("Broadcast reveal " <> word)
    game = Wordspy.GameServer.reveal(socket.assigns.game.name, word, :red)
    socket = assign(socket, game: game)
    {:noreply, socket}
  end

  @impl true
  def handle_info(message, socket) do
    IO.inspect(message, label: "Message received")
    # get the latest game summary and push
    socket = assign(socket, game: Wordspy.GameServer.summary(socket.assigns.game.name))
    {:noreply, socket}
  end

  def tile_classes(tile) do
    cond do
      tile.visibility == :revealed and tile.team == :red ->
        "bg-red-600 text-white shadow-inner cursor-default border-none border-black"
      tile.visibility == :revealed and tile.team == :blue ->
        "bg-blue-600 text-white shadow-inner cursor-default border-none border-black"
      tile.visibility == :revealed and tile.team == :bystander ->
        "bg-gray-500 text-black shadow-inner cursor-default border-none border-black"
      tile.visibility == :revealed and tile.team == :assassin ->
        "bg-black text-white shadow-inner cursor-default border-none border-black"
      true ->
        "bg-gray-300 text-black shadow border border-gray-600"
      end
  end

  defp game_topic(game) do
    "wordspy:" <> game
  end
end
