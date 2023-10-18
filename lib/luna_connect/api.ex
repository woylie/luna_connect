defmodule LunaConnect.API do
  @moduledoc """
  Defines an interface for the Lunatask API.
  """

  alias LunaConnect.Configuration

  @base_url "https://api.lunatask.app/v1"

  @connect_options [
    transport_opts: [cacertfile: Path.expand("./.cacerts/cacerts.pem")]
  ]

  def list_source_ids_by_source(source, %Configuration{
        access_token: access_token
      }) do
    (@base_url <> "/tasks")
    |> Req.get!(
      params: [source: source],
      auth: {:bearer, access_token},
      connect_options: @connect_options
    )
    |> Map.fetch!(:body)
    |> Map.fetch!("tasks")
    |> Enum.reject(&(&1["status"] == "completed"))
    |> Enum.map(fn %{"id" => id, "sources" => [%{"source_id" => source_id}]} ->
      {id, source_id}
    end)
  end

  def create_task(params, %Configuration{access_token: access_token}) do
    (@base_url <> "/tasks")
    |> Req.post!(
      json: params,
      auth: {:bearer, access_token},
      connect_options: @connect_options
    )
    |> extract_task()
  end

  defp extract_task(%Req.Response{status: 201, body: %{"task" => task}}) do
    case LunaConnect.Task.validate(task) do
      {:ok, task} -> {:ok, task}
      {:error, changeset} -> {:error, {:unexpected_response, changeset}}
    end
  end

  defp extract_task(%Req.Response{status: 204}) do
    {:error, :already_imported}
  end

  defp extract_task(%Req.Response{} = response) do
    {:error, {:unexpected_response, response}}
  end

  def complete_task(id, %Configuration{access_token: access_token}) do
    response =
      Req.put!(
        @base_url <> "/tasks/#{id}",
        json: %{status: "completed"},
        auth: {:bearer, access_token},
        connect_options: @connect_options
      )

    if response.status == 200, do: :ok, else: {:error, response.status}
  end
end
