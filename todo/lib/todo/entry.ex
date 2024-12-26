defmodule Todo.Entry do
  defstruct [:id, :date, :title]

  def new(id, date, title), do: %Todo.Entry{id: id, date: date, title: title}
end
