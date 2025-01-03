defmodule Todo.Database do
  @pool_size 3
  @db_folder "./.db"

  def start_link() do
    File.mkdir_p!(@db_folder)

    children = Enum.map(1..@pool_size, &worker_spec(&1 - 1))
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def store(key, term) do
    key
    |> worker_id()
    |> Todo.DatabaseWorker.store(key, term)
  end

  def get(key) do
    key
    |> worker_id()
    |> Todo.DatabaseWorker.get(key)
  end

  def delete(key) do
    key
    |> worker_id()
    |> Todo.DatabaseWorker.delete(key)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor,
    }
  end

  defp worker_id(key) do
    key |> :erlang.phash2(@pool_size)
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end
end
