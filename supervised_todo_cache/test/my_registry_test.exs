defmodule Todo.MyRegistry.Test do
  use ExUnit.Case

  test "happy path" do
    {:ok, _} = Todo.MyRegistry.start_link(nil)
    assert Todo.MyRegistry.register(:some_name) == :ok
    assert Todo.MyRegistry.register(:some_name) == :error

    assert is_pid(Todo.MyRegistry.lookup(:some_name)) == true
    assert Todo.MyRegistry.lookup(:unregistered_name) == nil
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
