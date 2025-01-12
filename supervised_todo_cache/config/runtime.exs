import Config

http_port =
  if config_env() == :test,
    do: System.get_env("TODO_TEST_HTTP_PORT", "5455"),
    else: System.get_env("TODO_HTTP_PORT", "5454")

config(:todo, http_port: String.to_integer(http_port))

db_folder =
  if config_env() == :test,
    do: System.get_env("TODO_TEST_DB_FOLDER", "./.db_test"),
    else: System.get_env("TODO_DB_FOLDER", "./.db")

config(:todo, db_folder: db_folder)
