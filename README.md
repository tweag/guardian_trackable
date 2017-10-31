# GuardianTrackable

A [Guardian](https://github.com/ueberauth/guardian) hook to track user sign in. Tracks the following values:

* `sign_in_count`      - Increased every time a sign in is made
* `current_sign_in_at` - A timestamp updated when the user signs in
* `last_sign_in_at`    - Holds the timestamp of the previous sign in
* `current_sign_in_ip` - The remote ip updated when the user sign in
* `last_sign_in_ip`    - Holds the remote ip of the previous sign in

## Installation

The package can be installed by adding `guardian_trackable` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:guardian_trackable, "~> 0.1.0"}
  ]
end
```

## Usage

To use it, you'll need to setup your schema like this:

```elixir
defmodule MyApp.User do
  use Ecto.Schema
  use GuardianTrackable.Schema

  schema "users" do
    field :email, :string
    guardian_trackable()
  end
end
```

Then, you can add the following configuration to your Guardian module:

```elixir
defmodule MyApp.Guardian do
  use Guardian, otp_app: :my_app

  @impl true
  def after_sign_in(conn, resource, _token, _claims, _opts) do
    GuardianTrackable.track!(MyApp.Repo, conn, resource)
    {:ok, conn}
  end
end
```

## Running tests

Before you can run the tests, you'll need to setup a database:

```
$ mix ecto.setup
```

Now, run the tests:

```
$ mix test
```
