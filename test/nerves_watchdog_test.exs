defmodule NervesWatchdogTest do
  use ExUnit.Case, async: false
  doctest NervesWatchdog

  setup do
    Application.stop(:nerves_watchdog)
    revert_mfa = {__MODULE__, :revert, [self()]}
    reboot_mfa = {__MODULE__, :reboot, [self()]}
    Application.put_env(:nerves_watchdog, :revert_mfa, revert_mfa)
    Application.put_env(:nerves_watchdog, :reboot_mfa, reboot_mfa)
    Application.put_env(:nerves_watchdog, :timeout, 50)
    IO.inspect Application.start(:nerves_watchdog)
    Application.get_all_env(:nerves_watchdog)
  end

  def revert(pid) do
    send(pid, :revert)
  end

  def reboot(pid) do
    send(pid, :reboot)
  end

  test "revert is called on timeout" do
    assert_receive :revert
    Process.sleep(200)
    assert_receive :reboot
    assert Process.whereis(NervesWatchdog) == nil
  end

  test "revert is stopped after validation" do
    assert_receive :revert
    Process.sleep(25)
    NervesWatchdog.validate()
    assert_receive :revert
    Process.sleep(25)
    refute_receive :reboot
    assert Process.whereis(NervesWatchdog) == nil
  end
end
