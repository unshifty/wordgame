defmodule Wordspy do
  use Application

  def start(_, _) do
    children = [
      {Registry, keys: :unique, name: Wordspy.GameRegistry},
      Wordspy.WordCache,
      Wordspy.GameSupervisor
    ]

    opts = [strategy: :one_for_one, name: Wordspy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
