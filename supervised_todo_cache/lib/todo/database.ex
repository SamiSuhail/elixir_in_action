defmodule Todo.Database do
  use GenServer

  @db_folder "./.db"

  def start(), do: GenServer.start(__MODULE__, nil, name: __MODULE__)

  def store(key, term) do
    key
    |> chose_worker()
    |> Todo.DatabaseWorker.store(key, term)
  end

  def get(key) do
    key
    |> chose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  def delete(key) do
    key
    |> chose_worker()
    |> Todo.DatabaseWorker.delete(key)
  end

  defp chose_worker(key), do: GenServer.call(__MODULE__, {:chose_worker, key})

  @impl true
  def init(_) do
    IO.puts("Starting todo database.")
    File.mkdir_p!(@db_folder)
    {:ok, nil, {:continue, nil}}
  end

  @impl true
  def handle_continue(_continue_arg, _state) do
    File.mkdir_p!(@db_folder)

    pids = for num <- 0..2, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      {num, pid}
    end

    {:noreply, pids}
  end

  @impl true
  def handle_call({:chose_worker, key}, _, pids) do
    key_hash = :erlang.phash2(key, 3)
    {:reply, Map.get(pids, key_hash), pids}
  end
end
