defmodule LunaConnect.Linear do
  @moduledoc """
  Defines an interface for the Linear GraphQL API.
  """

  alias LunaConnect.Configuration

  @url "https://api.linear.app/graphql"

  @connect_options [
    transport_opts: [cacertfile: Path.expand("./.cacerts/cacerts.pem")]
  ]

  @doc """
  Fetches active issues from all teams (!).
  """
  @spec fetch_issues(Configuration.t()) :: list
  def fetch_issues(
        %Configuration{
          linear: %Configuration.Linear{api_key: api_key}
        } = config
      )
      when is_binary(api_key) do
    query = """
    {
      issues (
        first: 200,
        filter: {
          state: {
            or: [
              {type: {eq: "unstarted"}},
              {type: {eq: "started"}}
            ]
          }
        }
      ) {
        nodes {
          id
          title
          description
          url
          team {
            name
          }
        }
      }
    }
    """

    body = %{query: query}

    @url
    |> Req.post!(
      json: body,
      auth: api_key,
      connect_options: @connect_options
    )
    |> Map.fetch!(:body)
    |> Map.fetch!("data")
    |> Map.fetch!("issues")
    |> Map.fetch!("nodes")
    |> Enum.map(&issue_to_task(&1, config))
  end

  def fetch_issues(%Configuration{}) do
    raise "No Linear API key configured."
  end

  def issue_to_task(
        %{
          "description" => description,
          "id" => id,
          "team" => %{"name" => team_name},
          "title" => title,
          "url" => url
        },
        %Configuration{linear: %Configuration.Linear{default_area_id: area_id}}
      ) do
    note = """
    #{url}

    #{description}
    """

    %{
      area_id: area_id,
      name: "#{team_name}: #{title}",
      note: note,
      source: "linear",
      source_id: id
    }
  end
end
