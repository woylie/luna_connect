defmodule LunaConnect.CLI do
  @moduledoc """
  Defines the CLI interface.
  """

  alias LunaConnect.API
  alias LunaConnect.Configuration
  alias LunaConnect.GH
  alias LunaConnect.Linear

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

  def main(["gh" | ["update" | _]]) do
    config = Configuration.read_config()

    IO.puts("Loading assigned issues from Github")

    issue_ids =
      config
      |> GH.fetch_issues()
      |> Enum.map(fn %{"id" => id} -> id end)

    IO.puts("Loading requested PR reviews from Github")

    pr_ids =
      config
      |> GH.fetch_requested_reviews()
      |> Enum.map(fn %{"id" => id} -> id end)

    all_issue_ids = issue_ids ++ pr_ids

    IO.puts("Loading tasks")

    tasks = API.list_source_ids_by_source("github", config)

    IO.puts("\nTask unchanged: .")
    IO.puts("Task marked as completed: o")
    IO.puts("Error updating task: x\n")

    Enum.map(tasks, &maybe_mark_completed(&1, all_issue_ids, config))
  end

  def main(["linear" | _]) do
    config = Configuration.read_config()

    IO.puts("Loading assigned issues from Linear")

    config
    |> Linear.fetch_issues()
    |> Enum.map(fn issue ->
      response = API.create_task(issue, config)
      print_response(issue, response)
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
    luco gh update - Update statuses of tasks imported from Github
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

  defp maybe_mark_completed({task_id, issue_id}, all_issue_ids, config) do
    if issue_id in all_issue_ids do
      IO.write(".")
    else
      case API.complete_task(task_id, config) do
        :ok -> IO.write("o")
        {:error, _} -> IO.puts("x")
      end
    end
  end
end
