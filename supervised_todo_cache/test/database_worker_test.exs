defmodule Todo.DatabaseWorker.Test do
  use ExUnit.Case
  @db_folder "./.db"

  setup_all _ do
    File.mkdir_p!(@db_folder)
  end

  test "happy path" do
    key = UUID.uuid4()
    term = Todo.List.new()

    {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)

    Todo.DatabaseWorker.store(pid, key, term)
    assert Todo.DatabaseWorker.get(pid, key) == term

    Todo.DatabaseWorker.delete(pid, key)
    assert Todo.DatabaseWorker.get(pid, key) == nil
  end
end
