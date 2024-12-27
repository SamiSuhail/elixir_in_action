defmodule Todo.Cache do
  use GenServer

  def start() do
    Todo.Database.start()
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, name), do: GenServer.call(cache_pid, {:server_process, name})

  @impl true
  def init(_), do: {:ok, %{}}

  @impl true
  def handle_call({:server_process, name}, _, server_processes) do
    case Map.fetch(server_processes, name) do
      {:ok, server_process} ->
        {:reply, server_process, server_processes}

      :error ->
        {:ok, server_process} = Todo.Server.start(name)
        server_processes = Map.put(server_processes, name, server_process)
        {:reply, server_process, server_processes}
    end
  end
end
