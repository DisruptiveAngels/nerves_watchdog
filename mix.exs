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

  # Run "mix help compile.app" to learn about applications.
  def application, do: application(Mix.env)
  
  def application(:test) do
    [extra_applications: [:logger]]
  end

  def application(_) do
    [
      extra_applications: [:logger],
      mod: {NervesWatchdog.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves_runtime, "~> 0.5"}
    ]
  end
end
