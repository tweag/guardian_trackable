{:ok, _} = Application.ensure_all_started(:postgrex)
{:ok, _} = GuardianTrackable.Dummy.Repo.start_link()

ExUnit.start()
