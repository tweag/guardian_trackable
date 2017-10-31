defmodule GuardianTrackable.Dummy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
    end
  end
end
