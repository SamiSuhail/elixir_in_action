defmodule Todo.MyRegistry.Test do
  use ExUnit.Case

  test "happy path" do
    {:ok, _pid} = Todo.MyRegistry.start_link(nil)
    :ok = Todo.MyRegistry.register(:some_name)
    :error = Todo.MyRegistry.register(:some_name)
    found_pid = Todo.MyRegistry.lookup(:some_name)
    not_found_pid = Todo.MyRegistry.lookup(:unregistered_name)

    assert is_pid(found_pid) == true
    assert not_found_pid == nil
  end

  test "registry traps exits and deregisters process" do
    {:ok, _} = Todo.MyRegistry.start_link(nil)

    pid =
      spawn(fn ->
        :ok = Todo.MyRegistry.register(:some_name)
        loop()
      end)

    Process.sleep(100)
    assert pid == Todo.MyRegistry.lookup(:some_name)

    Process.exit(pid, :abnormal)
    Process.sleep(100)
    assert nil == Todo.MyRegistry.lookup(:some_name)
  end

  defp loop() do
    loop()
  end
end
