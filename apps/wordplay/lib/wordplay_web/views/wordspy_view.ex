defmodule WordplayWeb.WordspyView do
  use WordplayWeb, :view

  def game_count() do
    Wordspy.GameSupervisor.game_names |> Enum.count()
  end
end
