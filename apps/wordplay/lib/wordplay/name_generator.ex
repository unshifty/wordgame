defmodule Wordplay.NameGenerator do

  @doc """
  Generates a unique, URL-friendly name such as "bold-frog-8249".
  """
  def generate do
    generate(adjectives(), nouns())
  end

  def generate(list_one, list_two) do
    [
      Enum.random(list_one) |> String.downcase,
      Enum.random(list_two) |> String.downcase,
      :rand.uniform(9999)
    ]
    |> Enum.join("-")
  end

  def adjectives do
    ~w(
      autumn hidden bitter sour sweet spicy hot
      misty silent empty dry wet dark summer
      icy delicate quiet white cool spring winter patient
      twilight dawn crimson wispy childish blue billowing
      broken cold damp falling frosty green long late lingering
      bold little morning muddy old red rough still small
      sparkling throbbing shy wandering wild black
      young holy solitary fragrant aged snowy proud floral
      restless divine polished ancient purple lively nameless
      fat hairy wild alpha beta gamma smart silly strong
      mighty super wide steamy
    )
  end

  def nouns do
    ~w(
      waterfall river breeze moon rain wind sea morning
      snow lake sunset pine shadow leaf dawn glitter forest
      hill cloud meadow sun glade brook bush dew dust field
      fire flower feather grass dirt mound pebble stone
      haze mountain night pond darkness snowflake silence
      sound sky shape surf thunder violet water wildflower
      wave water resonance sun wood dream cherry tree fog
      frost voice paper smoke star bathtub curtain shower
      phone mug note notebook stick branch sponge faucet card
      tube pen pencil book paper binder envelope sheet
      butterfly firefly bird eagle hawk raven crow penguin sparrow
      frog shark snake fish whale dolphin
    )
  end
end
