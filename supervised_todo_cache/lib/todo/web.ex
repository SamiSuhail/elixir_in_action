defmodule Todo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  post "/add-entry" do
    conn = Plug.Conn.fetch_query_params(conn)

    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Map.fetch!(conn.params, "date") |> Date.from_iso8601!()

    Todo.Cache.server_process(list_name)
    |> Todo.Server.add_entry(%Todo.Entry{date: date, title: title})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.resp(201, "Created")
  end

  get "entries" do
    conn = Plug.Conn.fetch_query_params(conn)

    list_name = Map.fetch!(conn.params, "list")
    date = Map.fetch!(conn.params, "date") |> Date.from_iso8601!()

    entries =
      Todo.Cache.server_process(list_name)
      |> Todo.Server.entries(date)

    conn
    |> Plug.Conn.put_resp_content_type("text/json")
    |> Plug.Conn.resp(200, JSON.encode!(entries))
  end

  def child_spec(_) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: 5454],
      plug: __MODULE__
    )
  end
end
