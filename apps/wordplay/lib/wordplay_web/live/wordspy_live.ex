defmodule WordplayWeb.WordspyLive do
  use WordplayWeb, :live_view
  require Logger

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

    red_count = Presence.count(game_topic(game_name), :team, :red)
    blue_count = Presence.count(game_topic(game_name), :team, :blue)
    spymaster_count = Presence.count(game_topic(game_name), :is_spymaster, true)

    # assign a random team to start out
    socket = assign(socket, team: Enum.random([:red, :blue]))

    # subscribe to pubsub messages for this specific game
    Phoenix.PubSub.subscribe(Wordplay.PubSub, game_topic(game_name))

    # self is the pid of this process
    # use the same topic as for getting game updates
    # socket.id is the key that identifies this specific instance
    # and the meta data is an empty map because there's no info to track
    # changes to the presence count are handled in
    case Presence.track(self(), game_topic(game_name), socket.id, %{
           team: socket.assigns.team,
           is_spymaster: false
         }) do
      {:error, error} -> IO.puts("Unable to track presence for " <> game_name <> ": " <> error)
      _ -> nil
    end

    socket =
      assign(socket,
        game: game,
        is_spymaster: false,
        user_count: %{blue: blue_count, red: red_count, spymasters: spymaster_count}
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("reveal", %{"word" => word}, socket) do
    game = Wordspy.GameServer.reveal(socket.assigns.game.name, word)

    broadcast_game_update(game.name, :word_reveal)

    socket = assign(socket, game: game)
    {:noreply, socket}
  end

  def handle_event("new_game", _, socket) do
    # create a new game and broadcast to everyone else
    game = Wordspy.GameServer.new_game(socket.assigns.game.name, socket.assigns.game.wordlib)
    broadcast_game_update(game.name, :new_game)

    # remove spymaster designation from presence and socket
    broadcast_presence_update(socket, :is_spymaster, false)

    socket = assign(socket, game: game, is_spymaster: false)
    {:noreply, socket}
  end

  def handle_event("spymaster_clicked", _, socket) do
    # check how many spymasters are present
    if Presence.count(game_topic(socket.assigns.game.name), :is_spymaster, true) < 2 do
      # if room for one more, update presence and set in socket
      broadcast_presence_update(socket, :is_spymaster, true)
      socket = assign(socket, is_spymaster: true)
      {:noreply, socket}
    else
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
    # update socket
    socket = assign(socket, team: String.to_existing_atom(team))
    IO.inspect(socket)
    # update presence with the chosen side
    broadcast_presence_update(socket, :team, socket.assigns.team)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        %{
          assigns: %{user_count: %{red: red_count, blue: blue_count, spymasters: spymaster_count}}
        } = socket
      ) do
    Logger.debug("presence joins: #{inspect(joins)}")
    Logger.debug("presence leaves: #{inspect(leaves)}")

    red_count =
      red_count + Presence.count(joins, :team, :red) - Presence.count(leaves, :team, :red)

    blue_count =
      blue_count + Presence.count(joins, :team, :blue) - Presence.count(leaves, :team, :blue)

    spymaster_count =
      spymaster_count + Presence.count(joins, :is_spymaster, true) -
        Presence.count(leaves, :is_spymaster, true)

    socket =
      assign(socket, user_count: %{red: red_count, blue: blue_count, spymasters: spymaster_count})

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{game_event: :new_game = event}, socket) do
    # new game, so give up spymaster designation in presence and socket
    broadcast_presence_update(socket, :is_spymaster, false)
    socket = assign(socket, is_spymaster: false)
    handle_game_event(event, socket)
  end

  @impl true
  def handle_info(%{game_event: event}, socket) do
    handle_game_event(event, socket)
  end

  @impl true
  def handle_info(message, socket) do
    Logger.warn("Unhandled message: #{inspect(message)}")
    {:noreply, socket}
  end

  defp handle_game_event(_event, socket) do
    # get the latest game summary and push
    socket = assign(socket, game: Wordspy.GameServer.summary(socket.assigns.game.name))
    {:noreply, socket}
  end

  defp broadcast_game_update(game_name, event) do
    Phoenix.PubSub.broadcast_from(
      Wordplay.PubSub,
      self(),
      game_topic(game_name),
      %{game_event: event}
    )
  end

  defp broadcast_presence_update(socket, key, value) do
    Presence.update(self(), game_topic(socket.assigns.game.name), socket.id, fn meta ->
      Map.put(meta, key, value)
    end)
  end

  defp game_topic(game_name) do
    "wordspy:" <> game_name
  end
end
