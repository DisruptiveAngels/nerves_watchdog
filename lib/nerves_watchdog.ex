defmodule NervesWatchdog do
  use GenServer

  @timeout 1000 * 60 * 5 # 5 minutes

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  def init(opts) do
    timeout = opts[:timeout] || @timeout
    Nerves.Runtime.revert(reboot: false)
    {:ok, %{
      timer_t: Process.send_after(self(), :timeout, timeout),
      timeout: timeout,
      reverted?: true
    }}
  end

  def handle_info(:timeout, %{reverted?: reverted} = s) do
    if reverted?, do: Nerves.Runtime.reboot
    {:stop, :normal, s}
  end
end
