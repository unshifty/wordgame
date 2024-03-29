defmodule Wordspy.WordCache do
  use Agent
  require Logger

  def start_link(_) do
    standard = load_word_list("priv/word_lists/wordlist_codenames.txt")
    duet = load_word_list("priv/word_lists/wordlist_duet.txt")

    default = Enum.concat(standard, duet)
    undercover = load_word_list("priv/word_lists/wordlist_undercover.txt")
    combo = Enum.concat(default, undercover)

    Logger.info("Loaded word lists")

    Agent.start_link(fn -> %{default: default, dirty: undercover, combo: combo} end,
      name: __MODULE__
    )
  end

  def wordlist(wordlib) do
    Agent.get(__MODULE__, &Map.get(&1, wordlib))
  end

  def generate_wordset(library, num) do
    wordlist(library)
    |> Enum.take_random(num)
  end

  defp load_word_list(path) do
    Application.app_dir(:wordspy, path)
    # get the aboslute path
    |> Path.expand(__DIR__)
    # read the file (throw if error) as a string
    |> File.read!()
    # split the string on newline, removing leading and trailing whitespace
    |> String.split("\r\n", trim: true)
  end
end
