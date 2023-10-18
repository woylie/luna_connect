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
  def main(["gh" | ["reviews" | _]]) do
    config = Configuration.read_config()

    config
    |> GH.fetch_requested_reviews()
    |> Enum.map(fn pr ->
      params = GH.requested_review_to_task(pr, config)
      response = API.create_task(params, config)
      print_response(params, response)
    end)
  end

  def main(["gh" | ["issues" | _]]) do
    config = Configuration.read_config()

    config
    |> GH.fetch_issues()
    |> Enum.map(fn issue ->
      params = GH.issue_to_task(issue, config)
      response = API.create_task(params, config)
      print_response(params, response)
    end)
  end

  def main(["config" | _]) do
    config = Configuration.read_config()
    IO.puts("#{inspect(config, pretty: true)}")
  end

  def main(_) do
    IO.puts("""
    luco gh issues - Import open GH issues assigned to @me
    luco gh reviews - Import requested PR reviews
    """)
  end

  defp print_response(%{name: name}, {:ok, _}) do
    IO.puts("Task created: #{name}")
  end

  defp print_response(%{name: name}, {:error, :already_imported}) do
    IO.puts("Already imported, skipped: #{name}")
  end

  defp print_response(%{name: name}, {:error, {:unexpected_response, response}}) do
    IO.puts("Unexpected response for: #{name}")
    IO.puts("#{inspect(response, pretty: true)}")
  end
end
