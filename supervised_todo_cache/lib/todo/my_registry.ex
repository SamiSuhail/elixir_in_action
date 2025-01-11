defmodule Todo.MyRegistry do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    server_pid = Process.whereis(__MODULE__)
    Process.link(server_pid)
    if :ets.insert_new(__MODULE__, {name, self()}) do
      :ok
    else
      :error
    end
  end

  def lookup(name) do
    case :ets.lookup(__MODULE__, name) do
      [] -> nil
      [{_, pid}] -> pid
    end
  end

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true])
    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, state) do
    IO.puts("deleting...")
    :ets.match_delete(__MODULE__, {:_, pid})
    {:noreply, state}
  end
end
