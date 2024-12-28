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

    pids = 0..2
    |> Enum.map(fn num ->
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      {num, pid}
    end)
    |> Map.new()

    {:noreply, pids}
  end

  @impl true
  def handle_cast({:store, key, term}, pids) do
    pid = worker_pid(pids, key)
    Todo.DatabaseWorker.store(pid, key, term)

    {:noreply, pids}
  end

  def handle_cast({:delete, key}, pids) do
    pid = worker_pid(pids, key)
    Todo.DatabaseWorker.delete(pid, key)

    {:noreply, pids}
  end

  @impl true
  def handle_call({:get, key}, _, pids) do
    pid = worker_pid(pids, key)
    term = Todo.DatabaseWorker.get(pid, key)

    {:reply, term, pids}
  end

  defp worker_pid(pids, key) do
    key_hash = :erlang.phash2(key, 3)
    Map.get(pids, key_hash)
  end
end
