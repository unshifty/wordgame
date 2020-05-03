defmodule Wordspy.Tile do
  defstruct [:word, :team, :visibility, :revealed_by]

  alias __MODULE__

  def new(word, team) do
    %Tile{
      word: word,
      team: team,
      visibility: :hidden,
      revealed_by: nil
    }
  end

  def reveal(tile, team) do
    # sets the visiblity and revealed_by keys on tile and returns a new Tile
    %Tile{tile | visibility: :revealed, revealed_by: team}
  end
end
