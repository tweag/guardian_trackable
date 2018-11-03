defmodule Mix.Tasks.Guardian.Db.Gen.MigrationTest do
  use GuardianTrackable.DataCase, async: true

  import Mix.Tasks.GuardianTrackable.Install, only: [run: 1]
  import ExUnit.CaptureIO

  @tmp_path Path.join(["priv", "tmp"])
  @migrations_path Path.join([@tmp_path, "migrations"])

  defmodule DoubleDummy.Repo do
    def __adapter__ do
      true
    end

    def config do
      [
        priv: "priv/tmp/double_dummy",
        otp_app: :guardian_trackable
      ]
    end
  end

  setup_all do
    Application.put_env(
      :guardian_trackable,
      GuardianTrackable.Dummy.Repo,
      priv: "priv/tmp"
    )
  end

  setup do
    on_exit(fn -> File.rm_rf!(@tmp_path) end)
    :ok
  end

  defp silent_run(args) do
    capture_io(fn -> run(args) end)
  end

  test "generates a new migration" do
    silent_run([])

    assert name = File.ls!(@migrations_path) |> List.last()
    assert String.match?(name, ~r/^\d{14}_guardian_trackable\.exs$/)
  end

  test "generates a new migration with repo" do
    silent_run(["-r", to_string(DoubleDummy.Repo)])

    assert name = File.ls!("priv/tmp/double_dummy/migrations") |> List.last()
    assert String.match?(name, ~r/^\d{14}_guardian_trackable\.exs$/)
  end

  test "generates a new migration with schema" do
    silent_run(["--schema", "accounts"])

    assert name = File.ls!(@migrations_path) |> List.last()

    assert @migrations_path
           |> Path.join(name)
           |> File.read!()
           |> String.match?(~r/:accounts/)
  end
end
