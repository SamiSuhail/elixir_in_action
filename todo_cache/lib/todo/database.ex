defmodule Todo.Database do
  use GenServer

  @db_folder "./.db"

  def start(), do: GenServer.start(__MODULE__, nil, name: __MODULE__)

  def store(key, term), do: GenServer.cast(__MODULE__, {:store, key, term})

  def delete(key), do: GenServer.cast(__MODULE__, {:delete, key})

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  @impl true
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil, {:continue, nil}}
  end

  @impl true
  def handle_continue(_continue_arg, _state) do
    File.mkdir_p!(@db_folder)

    initial_state = %{
      0 => Todo.DatabaseWorker.start(@db_folder),
      1 => Todo.DatabaseWorker.start(@db_folder),
      2 => Todo.DatabaseWorker.start(@db_folder),
    }

    {:noreply, initial_state}
  end

  @impl true
  def handle_cast({:store, key, term}, state) do
    file_name(key)
    |> File.write!(:erlang.term_to_binary(term))

    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    file_name(key)
    |> File.rm!()

    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    path =
      Path.expand(file_name(key))

    term =
      case File.read(path) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, term, state}
  end

  defp file_name(key), do: Path.join(@db_folder, to_string(key))
end
