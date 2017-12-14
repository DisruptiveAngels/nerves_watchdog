defmodule NervesWatchdog do
  use GenServer

  @timeout 1000 * 60 * 5 # 5 minutes

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def validate() do
    GenServer.call(__MODULE__, :validate)
  end

  def init(opts) do
    timeout = opts[:timeout] || @timeout
    revert_mfa = opts[:revert_mfa] || {Nerves.Runtime, :revert, [[reboot: false]]}
    reboot_mfa = opts[:reboot_mfa] || {Nerves.Runtime, :reboot, []}
    
    apply(revert_mfa)
    {:ok, %{
      timer_ref: Process.send_after(self(), :timeout, timeout),
      timeout: timeout,
      reverted?: true,
      reboot_mfa: reboot_mfa,
      revert_mfa: revert_mfa
    }}
  end

  def handle_call(:validate, _from, %{reverted?: reverted?, revert_mfa: {m, f, a}} = s) do
    if reverted?, do: apply(m, f, a)
    Process.cancel_timer(s.timer_ref)
    {:stop, :normal, :ok, %{reverted?: false, timer_ref: nil}}
  end

  def handle_info(:timeout, %{reverted?: reverted?, reboot_mfa: {m, f, a}} = s) do
    if reverted?, do: apply(m, f, a)
    {:stop, :normal, s}
  end

  defp apply({m, f, a}) do
    apply(m, f, a)
  end
end
