defmodule Wordplay.NameGenerator do
  @doc """
  Generates a unique, URL-friendly name such as "bold-frog-8249".
  """
  def generate do
    generate(adjectives(), nouns())
  end

  def generate(list_one, list_two) do
    [
      Enum.random(list_one) |> String.downcase(),
      Enum.random(list_two) |> String.downcase()
      # Enum.random(list_two) |> String.downcase()
      # :rand.uniform(9999)
    ]
    |> Enum.join("-")
  end

  def adjectives() do
    load_word_list("../../data/adjectives_1.txt")
  end

  def nouns() do
    load_word_list("../../data/nouns.txt")
  end

  defp load_word_list(path) do
    path
    # get the aboslute path
    |> Path.expand(__DIR__)
    # read the file (throw if error) as a string
    |> File.read!()
    # split the string on newline, removing leading and trailing whitespace
    |> String.split("\r\n", trim: true)
  end
end
