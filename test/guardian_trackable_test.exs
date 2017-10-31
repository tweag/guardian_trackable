defmodule GuardianTrackableTest do
  use GuardianTrackable.DataCase, async: true
  doctest GuardianTrackable

  alias GuardianTrackable.Dummy.{Repo, User, Guardian}

  setup do
    [user: Repo.insert!(%User{email: "user@example.com"})]
  end

  def make_conn(ip) do
    %Plug.Conn{remote_ip: ip}
  end

  test "after_sign_in/5 initial sign in", %{user: user} do
    {127, 0, 0, 1}
    |> make_conn()
    |> Guardian.Plug.sign_in(user)

    user = Repo.reload!(user)

    assert user.sign_in_count == 1
    assert user.current_sign_in_ip == "127.0.0.1"
    assert user.last_sign_in_ip == "127.0.0.1"
    assert user.current_sign_in_at == user.last_sign_in_at
  end

  test "after_sign_in/5 second sign in", %{user: user} do
    conn1 = make_conn({127, 0, 0, 1})
    conn2 = make_conn({1, 1, 1, 1})

    Guardian.Plug.sign_in(conn1, user)
    Guardian.Plug.sign_in(conn2, Repo.reload!(user))

    user = Repo.reload!(user)

    assert user.sign_in_count == 2
    assert user.current_sign_in_ip == "1.1.1.1"
    assert user.last_sign_in_ip == "127.0.0.1"
    assert user.current_sign_in_at != user.last_sign_in_at
  end
end
