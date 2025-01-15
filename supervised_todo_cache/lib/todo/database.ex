defmodule Todo.Database do
  @pool_size 3

  def child_spec(_) do
    db_folder_root = Application.fetch_env!(:todo, :db_folder)
    [node_prefix, _] = node() |> to_string() |> String.split("@")
    db_folder = Path.join(db_folder_root, node_prefix)
    File.mkdir_p!(db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size,
      ],
      [db_folder]
    )
  end

  def store(key, term) do
    :poolboy.transaction(__MODULE__, fn pid -> Todo.DatabaseWorker.store(pid, key, term) end)
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, fn pid -> Todo.DatabaseWorker.get(pid, key) end)
  end

  def delete(key) do
    :poolboy.transaction(__MODULE__, fn pid -> Todo.DatabaseWorker.delete(pid, key) end)
  end
end
