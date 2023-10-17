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

    config
    |> GH.fetch_issues()
    |> Enum.map(&GH.issue_to_task(&1, config))
    |> Enum.map(&{&1, API.create_task(&1, config)})
    |> Enum.map(&print_response/1)
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

  defp print_response({%{name: name}, {:ok, _}}) do
    IO.puts("Task created: #{name}")
  end

  defp print_response({%{name: name}, {:error, :already_imported}}) do
    IO.puts("Already imported, skipped: #{name}")
  end

  defp print_response(
         {%{name: name}, {:error, {:unexpected_response, response}}}
       ) do
    IO.puts("Unexpected response for: #{name}")
    IO.puts("#{inspect(response, pretty: true)}")
  end
end
