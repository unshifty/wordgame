defmodule WordspyWeb.WordspyView do
  use WordspyWeb, :view

  def game_count() do
    Wordspy.GameSupervisor.game_names() |> Enum.count()
  end
end
