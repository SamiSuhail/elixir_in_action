defmodule Todo.Cache.Test do
  use ExUnit.Case

  test "happy path" do
    # Arrange
    {:ok, cache_pid} = Todo.Cache.start()
    server_name = UUID.uuid4()
    server_pid = Todo.Cache.server_process(cache_pid, server_name)

    # Act + Assert
    new_entry = %Todo.Entry{date: ~D[2024-02-02], title: "Entry 1"}
    assert Todo.Server.add_entry(server_pid, new_entry) == :ok
    assert Todo.Server.entries(server_pid, ~D[2024-02-02]) == [%Todo.Entry{id: 1, date: ~D[2024-02-02], title: "Entry 1"}]
  end
end
