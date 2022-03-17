defmodule WordspyWeb.PageController do
  use WordspyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
