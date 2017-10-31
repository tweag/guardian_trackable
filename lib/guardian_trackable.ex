defmodule GuardianTrackable do
  @moduledoc """
  Saves tracking information to your user schemas.
  """

  alias GuardianTrackable.Schema

  defmacro __using__(opts) do
    repo = Keyword.fetch!(opts, :repo)

    quote do
      @impl true
      def after_sign_in(conn, resource, _token, _claims, _opts) do
        GuardianTrackable.track!(unquote(repo), conn, resource)
        {:ok, conn}
      end
    end
  end

  def track!(repo, conn, resource) do
    resource
    |> Schema.trackable_changeset(conn.remote_ip)
    |> repo.update!
  end
end
