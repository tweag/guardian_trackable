defmodule GuardianTrackable.DataCase do
  use ExUnit.CaseTemplate

  alias GuardianTrackable.Dummy.Repo

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
