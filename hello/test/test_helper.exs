ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Hello.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Hello.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Hello.Repo)

