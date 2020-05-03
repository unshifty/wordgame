defmodule WordplayWeb.WordspyController do
  use WordplayWeb, :controller

  def new(conn, _) do
    render(conn, "new.html")
  end

  def create(conn, %{"game" => %{"name" => name, "wordlist" => wordlist}}) do
    name = get_name(name)
    case Wordspy.GameSupervisor.start_game(name, String.to_existing_atom(wordlist)) do
      {:ok, _} ->
        redirect(conn, to: Routes.wordspy_path(conn, :index, name))
      {:error, _error} ->
        conn
        |> put_flash(:error, "Unable to create game!")
        |> redirect(to: Routes.wordspy_path(conn, :new))
    end
  end

  defp get_name(name) when name == "" do
    Wordplay.NameGenerator.generate()
  end
  defp get_name(name), do: name

end
