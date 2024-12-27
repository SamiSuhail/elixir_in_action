defmodule Todo.List do

  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, &(add_entry(&2, &1)))
  end

  def add_entry(%Todo.List{} = todo_list, %{date: date, title: title}) do
    entry = Todo.Entry.new(todo_list.next_id, date, title)
    entries = Map.put(todo_list.entries, todo_list.next_id, entry)
    %Todo.List{todo_list | next_id: entry.id + 1, entries: entries}
  end

  def entries(%Todo.List{} = todo_list, date) do
    Map.values(todo_list.entries)
      |> Enum.filter(&(&1.date == date))
  end

  def update_entry(%Todo.List{} = todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, entry} ->
        put_in(todo_list.entries[entry_id], updater_fun.(entry))
    end
  end

  def delete_entry(%Todo.List{} = todo_list, entry_id) do
    updated_entries = todo_list.entries |> Map.delete(entry_id)
    %Todo.List{todo_list | entries: updated_entries}
  end
end
