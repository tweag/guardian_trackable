defmodule GuardianTrackable.Schema do
  defmacro __using__(_) do
    quote do
      import GuardianTrackable.Schema
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
end
