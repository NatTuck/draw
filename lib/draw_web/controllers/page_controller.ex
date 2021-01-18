defmodule DrawWeb.PageController do
  use DrawWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def join(conn, %{"name" => name}) do
    conn
    |> put_session(:user, name)
    |> redirect(to: Routes.page_path(conn, :play))
  end

  def leave(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:notice, "left game")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def play(conn, _params) do
    if conn.assigns[:user] do
      render conn, "play.html"
    else
      conn
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end
end
