defmodule NervesWatchdog.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nerves_watchdog,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application() do
    [
      extra_applications: [:logger],
      mod: {NervesWatchdog.Application, []}
    ]
  end

  defp deps do
    [
      {:nerves_runtime, "~> 0.5"}
    ]
  end
end
