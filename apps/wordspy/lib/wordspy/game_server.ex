defmodule Wordspy.GameServer do
  use GenServer

  @timeout :timer.hours(2)

  def start_link(name, wordlib) do
    GenServer.start_link(__MODULE__, {name, wordlib}, name: via_tuple(name))
  end

  def init({name, wordlib}) do
    game = Wordspy.Game.new(name, wordlib)
    {:ok, game, @timeout}
  end

  @doc """
  Returns the `pid` of the game server process registered under the
  given `game_name`, or `nil` if no process is registered.
  """
  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  def summary(game_name) do
    call(game_name, :summary)
  end

  def reveal(game_name, word) do
    call(game_name, {:reveal, word})
  end

  def end_turn(game_name) do
    call(game_name, :end_turn)
  end

  def new_game(game_name, wordlib) do
    call(game_name, {:new_game, wordlib})
  end

  def set_spymasters(game_name, spymasters) do
    call(game_name, {:set_spymasters, spymasters})
  end

    @doc """
  Returns a tuple used to register and lookup a game server process by name.
  """
  def via_tuple(game_name) do
    {:via, Registry, {Wordspy.GameRegistry, game_name}}
  end

  defp call(game_name, args) do
    GenServer.call(via_tuple(game_name), args)
  end

  def handle_call(:summary, _, game) do
    {:reply, game, game, @timeout}
  end

  def handle_call({:reveal, word}, _, game) do
    new_game = Wordspy.Game.reveal(game, word)
    {:reply, new_game, new_game, @timeout}
  end

  def handle_call(:end_turn, _, game) do
    new_game = Wordspy.Game.end_turn(game)
    {:reply, new_game, new_game, @timeout}
  end

  def handle_call({:new_game, wordlib}, _, game) do
    new_game = Wordspy.Game.new(game.name, wordlib)
    {:reply, new_game, new_game, @timeout}
  end

  def handle_call({:set_spymasters, spymasters}, _, game) do
    new_game = %Wordspy.Game{game | spymasters: spymasters}
    {:reply, new_game, new_game, @timeout}
  end

  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  def terminate({:shutdown, :timeout}, _game) do
    :ok
  end

  def terminate(_reason, _game) do
    :ok
  end

  defp game_name() do
    Registry.keys(Wordspy.GameRegistry, self()) |> List.first()
  end
end
