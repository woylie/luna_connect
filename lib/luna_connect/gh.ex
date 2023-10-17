defmodule LunaConnect.GH do
  @moduledoc """
  Defines an interface for the Github CLI.
  """

  alias LunaConnect.Configuration

  @doc """
  Fetches open issues assigned to the authenticated user.
  """
  @spec fetch_issues(Configuration.t()) :: list
  def fetch_issues(%Configuration{github: config}) do
    default_args = [
      "search",
      "issues",
      "--assignee",
      "@me",
      "--state",
      "open",
      "--json",
      "body,id,repository,title,url"
    ]

    args = add_reject_orgs_arg(default_args, config.ignored_organizations)
    {result, 0} = System.cmd("gh", args)
    Jason.decode!(result)
  end

  defp add_reject_orgs_arg(args, []), do: args

  defp add_reject_orgs_arg(args, orgs) do
    org_list = Enum.join(orgs, ",")
    args ++ ["--", "-org:#{org_list}"]
  end

  def issue_to_task(
        %{
          "body" => body,
          "id" => id,
          "repository" => %{"name" => repository_name},
          "title" => title,
          "url" => url
        },
        %{github: %{default_area_id: area_id}}
      ) do
    note = """
    #{url}

    #{body}
    """

    %{
      area_id: area_id,
      name: "#{repository_name}: #{title}",
      note: note,
      source: "github",
      source_id: id
    }
  end
end
