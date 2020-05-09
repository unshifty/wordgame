defmodule Wordspy.GameSupervisor do
  @moduledoc """
  Responsible for spinning up and supervising new GameServers
  """
  use DynamicSupervisor
  require Logger

  alias Wordspy.GameServer

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info("#{__MODULE__} started")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a GameServer process and supervises it.
  """
  def start_game(game_name) do
    start_game(game_name, :default)
  end

  def start_game(game_name, wordlib) do
    child_spec = %{
      id: GameServer,
      # to start this child, call start_link and pass it game_name
      start: {GameServer, :start_link, [game_name, wordlib]},
      # restart if there's an abnormal termination, doesn't include timeouts
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def game_names() do
    # get the children with id __MODULE__
    DynamicSupervisor.which_children(__MODULE__)
    # Lookup the names by id in the registry
    |> Enum.map(fn {_, game_pid, _, _} ->
      Registry.keys(Wordspy.GameRegistry, game_pid) |> List.first
    end)
    |> Enum.sort
  end

end
