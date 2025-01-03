defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}),
    do: GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))

  def store(worker_id, key, term),
    do:
      via_tuple(worker_id)
      |> GenServer.cast({:store, key, term})

  def delete(worker_id, key),
    do:
      via_tuple(worker_id)
      |> GenServer.cast({:delete, key})

  def get(worker_id, key),
    do:
      via_tuple(worker_id)
      |> GenServer.call({:get, key})

  defp via_tuple(key),
    do: Todo.ProcessRegistry.via_tuple({__MODULE__, key})

  @impl true
  def init(db_folder) do
    IO.puts("Starting todo database worker.")
    {:ok, db_folder}
  end

  @impl true
  def handle_cast({:store, key, term}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(term))

    {:noreply, db_folder}
  end

  def handle_cast({:delete, key}, db_folder) do
    file_name(db_folder, key)
    |> File.rm!()

    {:noreply, db_folder}
  end

  @impl true
  def handle_call({:get, key}, _, db_folder) do
    path =
      Path.expand(file_name(db_folder, key))

    term =
      case File.read(path) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, term, db_folder}
  end

  defp file_name(db_folder, key), do: Path.join(db_folder, to_string(key))
end
