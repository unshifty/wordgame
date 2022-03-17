defmodule WordspyWeb.WordspyController do
  use WordspyWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"game" => %{"wordlist" => wordlib}}) do
    name = generate_name(String.to_existing_atom(wordlib))

    case Wordspy.GameSupervisor.start_game(name, String.to_existing_atom(wordlib)) do
      {:ok, _} ->
        redirect(conn, to: Routes.wordspy_path(conn, :show, name))

      {:error, _error} ->
        conn
        |> put_flash(:error, "Unable to create game!")
        |> redirect(to: Routes.wordspy_path(conn, :new))
    end
  end

  def show(conn, %{"game" => %{"name" => name}}) do
    redirect(conn, to: Routes.wordspy_path(conn, :show, name))
  end

  def show(conn, %{"id" => game_name} = params) do
    # first see if the game exists
    # if it does, live render the game
    # if it doesn't, show a flash message and redirect to the create page
    case Wordspy.GameServer.game_pid(game_name) do
      pid when is_pid(pid) ->
        live_render(conn, WordspyWeb.WordspyLive, session: params)

      nil ->
        conn
        |> put_flash(:error, "The game '" <> game_name <> "' has either ended, or never existed.")
        |> redirect(to: Routes.wordspy_path(conn, :new))
    end
  end

  defp generate_name(wordlib) do
    Wordspy.NameGenerator.generate(
      Wordspy.NameGenerator.adjectives(),
      Wordspy.WordCache.wordlist(wordlib)
    )
  end
end
