defmodule Todo.MyRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    GenServer.call(__MODULE__, {:register, name, self()})
  end

  def lookup(name) do
    GenServer.call(__MODULE__, {:lookup, name})
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:register, name, pid}, _, pids) do
    case Map.fetch(pids, name) do
      {:ok, _pid} -> {:reply, :error, pids}
      _ ->
        new_pids = Map.put_new(pids, name, pid)
        {:reply, :ok, new_pids}
    end
  end

  @impl GenServer
  def handle_call({:lookup, name}, _, pids) do
    pid = Map.get(pids, name)
    {:reply, pid, pids}
  end
end
