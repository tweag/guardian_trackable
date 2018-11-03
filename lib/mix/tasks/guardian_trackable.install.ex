defmodule Mix.Tasks.GuardianTrackable.Install do
  @shortdoc "Generates a new migration for GuardianTrackable"

  @moduledoc """
  Generates a migration.

  The repository must be set under `:ecto_repos` in the
  current app configuration or given via the `-r` option.

  This generator follows the functionality of `ecto.gen.migration`, so it will
  be created in the configured migration direction with a timestamp-prefixed
  filename.

  ## Examples

      mix guardian_trackable.install
      mix guardian_trackable.install -r Custom.Repo
      mix guardian_trackable.install --schema accounts

  ## Command line options

    * `-r`, `--repo` - the repo to generate migration for
    * `--schema` - the schema to generate migration for
  """
  use Mix.Task

  import Mix.Ecto
  import Mix.Generator

  @doc false
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [schema: :string])

    no_umbrella!("ecto.gen.migration")
    repos = parse_repo(args)

    Enum.each(repos, fn repo ->
      ensure_repo(repo, args)
      path = Ecto.Migrator.migrations_path(repo)
      file = Path.join(path, "#{timestamp()}_guardian_trackable.exs")
      create_directory(path)

      assigns = [
        mod: Module.concat([repo, Migrations, "GuardianTrackable"]) |> inspect,
        schema: Keyword.get(opts, :schema, "users")
      ]

      source_path =
        :guardian_trackable
        |> Application.app_dir()
        |> Path.join("priv/templates/migration.exs.eex")

      migration_template = EEx.eval_file(source_path, assigns)
      create_file(file, migration_template)
    end)
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
