defmodule WordplayWeb.WordspyController do
  use WordplayWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"game" => %{"name" => name, "wordlist" => wordlib}}) do
    name = get_or_generate_name(String.trim(name), String.to_existing_atom(wordlib))
    case Wordspy.GameSupervisor.start_game(name, String.to_existing_atom(wordlib)) do
      {:ok, _} ->
        redirect(conn, to: Routes.wordspy_path(conn, :show, name))
      {:error, _error} ->
        conn
        |> put_flash(:error, "Unable to create game!")
        |> redirect(to: Routes.wordspy_path(conn, :new))
    end
  end

  def show(conn, %{"id" => game_name} = params) do
    # first see if the game exists
    # if it does, live render the game
    # if it doesn't, show a flash message and redirect to the create page
    case Wordspy.GameServer.game_pid(game_name) do
      pid when is_pid(pid) ->
        live_render(conn, WordplayWeb.WordspyLive, session: params)

      nil ->
        conn
        |> put_flash(:error, "The game '" <> game_name <> "' has either ended, or never existed.")
        |> redirect(to: Routes.wordspy_path(conn, :new))
    end
  end

  defp get_or_generate_name(name, wordlib) when name == "" do
    Wordplay.NameGenerator.generate(Wordplay.NameGenerator.adjectives(), Wordspy.WordCache.wordlist(wordlib))
  end
  defp get_or_generate_name(name, _), do: name

end