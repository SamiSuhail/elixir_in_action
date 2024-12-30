defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    Todo.Database.start()
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(name), do: GenServer.call(__MODULE__, {:server_process, name})

  @impl true
  def init(_) do
    IO.puts("Starting todo cache.")
    {:ok, %{}}
  end

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
