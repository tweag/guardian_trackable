defmodule GuardianTrackable.Schema do
  @moduledoc """
  Track information about your user sign in. It tracks the following columns:

  * sign_in_count      - Increased every time a sign in is made
  * current_sign_in_at - A timestamp updated when the user signs in
  * last_sign_in_at    - Holds the timestamp of the previous sign in
  * current_sign_in_ip - The remote ip updated when the user sign in
  * last_sign_in_ip    - Holds the remote ip of the previous sign in
  """

  defmacro __using__(_) do
    quote do
      import GuardianTrackable.Schema, only: :macros
    end
  end

  defmacro guardian_trackable do
    quote do
      field :sign_in_count, :integer, default: 0
      field :last_sign_in_at, :utc_datetime
      field :last_sign_in_ip, :string
      field :current_sign_in_at, :utc_datetime
      field :current_sign_in_ip, :string
    end
  end

  def trackable_changeset(resource, ip_address) do
    now        = DateTime.utc_now
    ip_address = ip_address |> Tuple.to_list |> Enum.join(".")

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
