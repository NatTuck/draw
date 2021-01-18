defmodule DrawWeb.Plugs.FetchUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user = get_session(conn, :user)
    assign(conn, :user, user)
  end
end
