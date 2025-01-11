defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(db_folder),
    do: GenServer.start_link(__MODULE__, db_folder)

  def store(worker_pid, key, term),
    do: GenServer.cast(worker_pid, {:store, key, term})

  def delete(worker_pid, key),
    do: GenServer.cast(worker_pid, {:delete, key})

  def get(worker_pid, key),
    do: GenServer.call(worker_pid, {:get, key})

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
