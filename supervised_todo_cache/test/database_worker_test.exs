defmodule Todo.DatabaseWorker.Test do
  use ExUnit.Case
  @db_folder "./.db"

  setup_all _ do
    File.mkdir_p!(@db_folder)
  end

  test "happy path" do
    key = UUID.uuid4()
    term = Todo.List.new()

    worker_id = UUID.uuid4()
    Todo.DatabaseWorker.start_link({@db_folder, worker_id})

    Todo.DatabaseWorker.store(worker_id, key, term)
    assert Todo.DatabaseWorker.get(worker_id, key) == term

    Todo.DatabaseWorker.delete(worker_id, key)
    assert Todo.DatabaseWorker.get(worker_id, key) == nil
  end
end
