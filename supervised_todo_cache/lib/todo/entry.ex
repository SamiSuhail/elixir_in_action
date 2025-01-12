defmodule Todo.Entry do
  @derive JSON.Encoder
  defstruct [:id, :date, :title]

  def new(id, date, title), do: %Todo.Entry{id: id, date: date, title: title}
end
