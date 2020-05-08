defmodule WordplayWeb.WordspyView do
  use WordplayWeb, :view

  alias Wordspy.Game

  def game_count() do
    Wordspy.GameSupervisor.game_names() |> Enum.count()
  end
end
