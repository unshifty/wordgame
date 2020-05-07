defmodule WordplayWeb.WordspyLive do
  use WordplayWeb, :live_view

  alias WordplayWeb.{Presence}

  @impl true
  def mount(%{"id" => game_name}, _session, socket) do
    mount(game_name, socket)
  end

  @impl true
  def mount(:not_mounted_at_router, %{"id" => game_name}, socket) do
    mount(game_name, socket)
  end

  def mount(game_name, socket) do
    game = Wordspy.GameServer.summary(game_name)
    initial_player_count = player_count(game_name)

    # assign a random team to start out
    socket = assign(socket, :team, Enum.random([:red, :blue]))

    # subscribe to pubsub messages for this specific game
    Phoenix.PubSub.subscribe(Wordplay.PubSub, game_topic(game_name))

    # self is the pid of this process
    # use the same topic as for getting game updates
    # socket.id is the key that identifies this specific instance
    # and the meta data is an empty map because there's no info to track
    # changes to the presence count are handled in
    case Presence.track(self(), game_topic(game_name), socket.id, %{team: socket.assigns.team}) do
      {:error, error} -> IO.puts("Unable to track presence for " <> game_name <> ": " <> error)
      _ -> IO.puts("Tracking presence for " <> game_name)
    end

    socket = assign(socket, game: game, is_spymaster: false, player_count: initial_player_count)
    {:ok, socket}
  end

  @impl true
  def handle_event("reveal", %{"word" => word}, socket) do
    game = Wordspy.GameServer.reveal(socket.assigns.game.name, word, :red)

    broadcast_game_update(game.name, :word_reveal)

    socket = assign(socket, game: game)
    {:noreply, socket}
  end

  def handle_event("new_game", _, socket) do
    game = Wordspy.GameServer.new_game(socket.assigns.game.name, socket.assigns.game.wordlib)

    broadcast_game_update(game.name, :new_game)

    socket = assign(socket, game: game, is_spymaster: false)
    {:noreply, socket}
  end

  def handle_event("spymaster_clicked", _, socket) do
    spymasters = socket.assigns.game.spymasters
    if MapSet.size(spymasters) < 2 and not MapSet.member?(spymasters, socket.id) do
      IO.puts("adding " <> socket.id <> " to spymasters")
      game = Wordspy.GameServer.set_spymasters(socket.assigns.game.name, MapSet.put(spymasters, socket.id))

      broadcast_game_update(game.name, :spymasters_updated)

      socket = assign(socket, game: game, is_spymaster: true)
      {:noreply, socket}
    else
      IO.inspect(MapSet.to_list(spymasters), label: "There are already 2 spymasters")
      {:noreply, socket}
    end
  end

  def handle_event("end_turn", _, socket) do
    game = Wordspy.GameServer.end_turn(socket.assigns.game.name)

    broadcast_game_update(game.name, :end_turn)

    socket = assign(socket, game: game)
    {:noreply, socket}
  end

  def handle_event("choose_team", %{"team" => team}, socket) do
    # update presence with the chosen side
    Presence.update(self(), game_topic(socket.assigns.game.name), socket.id, fn m -> %{m | team: team} end)
    {:noreply, socket}
  end

  @impl true
  def handle_info(
    %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
    %{assigns: %{player_count: count}} = socket
  ) do
    IO.inspect(joins, label: "presence joins")
    IO.inspect(leaves, label: "presence leaves")
    player_count = count + map_size(joins) - map_size(leaves)

    # remove any spymasters that left
    if map_size(leaves) > 0 do
      spymasters =
        socket.assigns.game.spymasters
        |> MapSet.difference(MapSet.new(Map.keys(leaves)))
      game = Wordspy.GameServer.set_spymasters(socket.assigns.game.name, spymasters)

      broadcast_game_update(game.name, :spymasters_updated)

      socket = assign(socket, game: game, player_count: player_count)
      {:noreply, socket}
    else
      socket = assign(socket, player_count: player_count)
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%{game_event: _} = message, socket) do
    IO.inspect(message, label: "Game event received")
    # get the latest game summary and push
    socket = assign(socket, game: Wordspy.GameServer.summary(socket.assigns.game.name))
    {:noreply, socket}
  end

  @impl true
  def handle_info(message, socket) do
    IO.inspect(message, label: "Unhandled message")
    {:noreply, socket}
  end

  def tile_classes(%{visibility: :revealed} = tile, _) do
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
  def tile_classes(_, true) do
    "bg-gray-300 text-black border border-gray-400 cursor-default"
  end
  def tile_classes(_, false) do
    "bg-gray-300 text-black border border-gray-400 hover:shadow-md"
  end

  def word_classes(tile, is_spymaster) do
    cond do
      tile.visibility == :revealed or !is_spymaster ->
        ""
      is_spymaster and tile.team == :red ->
        "border-b-4 border-red-600 text-red-600"
      is_spymaster and tile.team == :blue ->
        "border-b-4 border-blue-600 text-blue-600"
      is_spymaster and tile.team == :bystander ->
        "border-b-4 border-gray-700 text-gray-700"
      is_spymaster and tile.team == :assassin ->
        "p-1 bg-black text-white rounded-lg"
    end
  end

  def on_click_event(assigns, word) do
    # only enable reveal if hidden and not spymaster
    if is_hidden(assigns.game, word) and not assigns.is_spymaster, do: "reveal", else: ""
  end

  def revealed_tiles(game, team) do
    Wordspy.Game.revealed_tiles(game, team)
  end

  def total_tiles(game, team) do
    Wordspy.Game.total_tiles(game, team)
  end

  defp is_hidden(game, word) do
    game.tiles[word].visibility == :hidden
  end

  defp broadcast_game_update(game_name, event) do
    Phoenix.PubSub.broadcast_from(
      Wordplay.PubSub,
      self(),
      game_topic(game_name),
      %{game_event: event}
    )
  end

  defp player_count(game_name) do
    Presence.list(game_topic(game_name)) |> map_size
  end

  defp game_topic(game_name) do
    "wordspy:" <> game_name
  end
end
