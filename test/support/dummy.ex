defmodule GuardianTrackable.Dummy.Repo do
  use Ecto.Repo, otp_app: :guardian_trackable

  def reload!(struct) do
    get!(struct.__struct__, struct.id)
  end
end

defmodule GuardianTrackable.Dummy.User do
  use Ecto.Schema
  use GuardianTrackable.Schema

  schema "users" do
    field :email, :string
    guardian_trackable()
  end
end

defmodule GuardianTrackable.Dummy.Guardian do
  use Guardian, otp_app: :guardian_trackable
  alias GuardianTrackable.Dummy.{Repo, User}

  @impl true
  def subject_for_token(resource, _claims) do
    {:ok, resource.id}
  end

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    {:ok, Repo.get!(User, id)}
  end

  @impl true
  def after_sign_in(conn, resource, _, _, _) do
    GuardianTrackable.track!(Repo, resource, conn.remote_ip)
    {:ok, conn}
  end
end
