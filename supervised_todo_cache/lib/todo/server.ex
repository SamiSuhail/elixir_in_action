defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name),
    do:
      GenServer.start_link(__MODULE__, name,
        name: Todo.ProcessRegistry.via_tuple({__MODULE__, name})
      )

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

  def cleanup(todo_server) do
    GenServer.cast(todo_server, :cleanup)
  end

  @impl true
  def init(name) do
    IO.puts("Starting todo server.")
    {:ok, {name, nil}, {:continue, name}}
  end

  @impl true
  def handle_continue(name, _state) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}}
  end

  @impl true
  def handle_cast({:add, entry}, {name, todo_list}) do
    updated_todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, updated_todo_list)
    {:noreply, {name, updated_todo_list}}
  end

  def handle_cast({:update, entry_id, updater_fun}, {name, todo_list}) do
    updated_todo_list = Todo.List.update_entry(todo_list, entry_id, updater_fun)
    Todo.Database.store(name, updated_todo_list)
    {:noreply, {name, updated_todo_list}}
  end

  def handle_cast({:delete, entry_id}, {name, todo_list}) do
    updated_todo_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, updated_todo_list)
    {:noreply, {name, updated_todo_list}}
  end

  def handle_cast(:cleanup, {name, _todo_list}) do
    Todo.Database.delete(name)
    {:noreply, {name, Todo.List.new()}}
  end

  @impl true
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end
end
