defmodule Todo.Server do
  use GenServer

  def start(), do: GenServer.start(__MODULE__, nil)

  def add_entry(todo_server, entry) do
    GenServer.cast(todo_server, {:add, entry})
  end

  def update_entry(todo_server, entry_id, updater_fun) do
    GenServer.cast(todo_server, {:update, entry_id, updater_fun})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete, entry_id})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  def init(_), do: {:ok, Todo.List.new()}

  def handle_cast({:add, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  def handle_cast({:update, entry_id, updater_fun}, todo_list) do
    {:noreply, Todo.List.update_entry(todo_list, entry_id, updater_fun)}
  end

  def handle_cast({:delete, entry_id}, todo_list) do
    {:noreply, Todo.List.delete_entry(todo_list, entry_id)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end
end
