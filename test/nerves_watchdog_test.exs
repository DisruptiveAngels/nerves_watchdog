defmodule NervesWatchdogTest do
  use ExUnit.Case
  doctest NervesWatchdog

  setup do
    revert_mfa = {__MODULE__, :revert, [self()]}
    reboot_mfa = {__MODULE__, :reboot, [self()]}
    %{revert_mfa: revert_mfa, reboot_mfa: reboot_mfa}
  end
  

  def revert(pid) do
    send(pid, :revert)
  end

  def reboot(pid) do
    send(pid, :reboot)
  end

  test "revert is called on timeout", ctx do
    {:ok, pid} = NervesWatchdog.start_link(
      timeout: 100, 
      reboot_mfa: ctx.reboot_mfa, 
      revert_mfa: ctx.revert_mfa)
    assert_receive :revert
    Process.sleep(200)
    assert_receive :reboot
    refute Process.alive?(pid)
  end

  test "revert is stopped after validation", ctx do
    {:ok, pid} = NervesWatchdog.start_link(
      timeout: 200, 
      reboot_mfa: ctx.reboot_mfa, 
      revert_mfa: ctx.revert_mfa)
    assert_receive :revert
    Process.sleep(100)
    NervesWatchdog.validate()
    assert_receive :revert
    refute_receive :reboot
    refute Process.alive?(pid)
  end
end
