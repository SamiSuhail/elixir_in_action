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
end
