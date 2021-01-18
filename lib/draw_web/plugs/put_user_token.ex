defmodule DrawWeb.Plugs.PutUserToken do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if user = conn.assigns[:user] do
      token = Phoenix.Token.sign(conn, "user socket", user)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
