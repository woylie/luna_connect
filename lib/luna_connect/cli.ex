defmodule LunaConnect.CLI do
  @moduledoc """
  Defines the CLI interface.
  """

  alias LunaConnect.API
  alias LunaConnect.Configuration
  alias LunaConnect.GH

  @doc """
  Main function for the escript.
  """
  def main(["gh" | _]) do
    config = Configuration.read_config()

    result =
      config
      |> GH.fetch_issues()
      |> Enum.map(&GH.issue_to_task(&1, config))
      |> Enum.map(&API.create_task(&1, config))

    IO.puts("#{inspect(result, pretty: true)}")
  end

  def main(["config" | _]) do
    config = Configuration.read_config()
    IO.puts("#{inspect(config, pretty: true)}")
  end

  def main(_) do
    IO.puts("""
    luco gh - Import open GH issues assigned to @me
    """)
  end
end
