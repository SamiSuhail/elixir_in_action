defmodule Todo.DatabaseWorker.Test do
  use ExUnit.Case
  @db_folder "./.db"

  setup_all _ do
    File.mkdir_p!(@db_folder)
  end

  test "happy path" do
    key = "database worker happy path"
    term = Todo.List.new()

    {:ok, worker_pid} = Todo.DatabaseWorker.start(@db_folder)

    Todo.DatabaseWorker.store(worker_pid, key, term)
    stored_term = Todo.DatabaseWorker.get(worker_pid, key)

    assert stored_term == term
  end
end
