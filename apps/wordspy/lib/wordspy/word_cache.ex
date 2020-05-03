defmodule Wordspy.WordCache do
  use Agent

  def start_link(_) do
    standard = load_word_list("../../data/wordlist_codenames.txt")
    duet = load_word_list("../../data/wordlist_duet.txt")
    undercover = load_word_list("../../data/wordlist_undercover.txt")

    Agent.start_link(fn -> %{default: Enum.concat(standard, duet), dirty: undercover} end,
      name: __MODULE__
    )
  end

  def get_wordset(library, num) do
    Agent.get(__MODULE__, &Map.get(&1, library))
    |> Enum.take_random(num)
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
