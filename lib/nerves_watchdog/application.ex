defmodule NervesWatchdog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    args = Application.get_all_env(:nerves_watchdog)
    children = [
      # Starts a worker by calling: NervesWatchdog.Worker.start_link(arg)
      Supervisor.child_spec({NervesWatchdog, args}, restart: :transient)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NervesWatchdog.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
