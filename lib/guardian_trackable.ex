defmodule GuardianTrackable do
  @moduledoc """
  Track information about your user sign in. It tracks the following columns:

  * `sign_in_count`      - Increased every time a sign in is made
  * `current_sign_in_at` - A timestamp updated when the user signs in
  * `last_sign_in_at`    - Holds the timestamp of the previous sign in
  * `current_sign_in_ip` - The remote ip updated when the user sign in
  * `last_sign_in_ip`    - Holds the remote ip of the previous sign in

  To use it, you'll need to setup your schema like this:

      defmodule MyApp.User do
        use Ecto.Schema
        use GuardianTrackable.Schema

        schema "users" do
          guardian_trackable()
        end
      end

  Then, you can add the following configuration to your Guardian module:

      defmodule MyApp.Guardian do
        use Guardian, otp_app: :my_app

        @impl true
        def after_sign_in(conn, resource, _token, _claims, _opts) do
          GuardianTrackable.track!(MyApp.Repo, conn, resource)
          {:ok, conn}
        end
      end

  """

  @doc """
  Updates a resource with tracking information.

  ## Example

      iex> GuardianTrackable.track!(MyApp.Repo, user, conn)
      %User{
        current_sign_in_at: #DateTime<2017-10-31 19:42:42.372012Z>,
        current_sign_in_ip: "127.0.0.1",
        last_sign_in_at: #DateTime<2017-10-31 19:42:42.372012Z>,
        last_sign_in_ip: "127.0.0.1",
        sign_in_count: 1
      }

  """
  @spec track!(
    repo :: Ecto.Repo.t,
    conn :: Plug.Conn.t,
    resource :: Ecto.Schema.t
  ) :: Ecto.Schema.t | no_return
  def track!(repo, conn, resource) do
    resource
    |> trackable_changeset(conn)
    |> repo.update!
  end

  @doc """
  Creates a changeset for tracking.

  ## Example

      iex> GuardianTrackable.trackable_changeset(user, conn)
      %Ecto.Changset{changes: %{
        current_sign_in_at: #DateTime<2017-10-31 19:42:42.372012Z>,
        current_sign_in_ip: "127.0.0.1",
        last_sign_in_at: #DateTime<2017-10-31 19:42:42.372012Z>,
        last_sign_in_ip: "127.0.0.1",
        sign_in_count: 1
      }}

  """
  @spec trackable_changeset(
    resource :: Ecto.Schema.t,
    conn :: Plug.Conn.t
  ) :: Ecto.Changeset.t
  def trackable_changeset(resource, conn) do
    now        = DateTime.utc_now
    ip_address = conn.remote_ip |> Tuple.to_list |> Enum.join(".")

    old_at     = resource.current_sign_in_at
    old_ip     = resource.current_sign_in_ip
    old_count  = resource.sign_in_count

    params = %{
      sign_in_count: old_count + 1,
      current_sign_in_at: now,
      current_sign_in_ip: ip_address,
      last_sign_in_at: old_at || now,
      last_sign_in_ip: old_ip || ip_address
    }

    Ecto.Changeset.cast(resource, params, Map.keys(params))
  end
end
