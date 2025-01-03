defmodule Todo.Cache do
  def start_link do
    DynamicSupervisor.start_link(strategy: :one_for_one, name: __MODULE__)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor,
    }
  end

  def server_process(name) do
    case DynamicSupervisor.start_child(__MODULE__, {Todo.Server, name}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
