defmodule Draw.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DrawWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Draw.PubSub},
      # Start the Endpoint (http/https)
      DrawWeb.Endpoint,
      # Start a worker by calling: Draw.Worker.start_link(arg)
      # {Draw.Worker, arg}
      Draw.GameAgent,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Draw.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DrawWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
