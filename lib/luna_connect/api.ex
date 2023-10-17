defmodule LunaConnect.API do
  @moduledoc """
  Defines an interface for the Lunatask API.
  """

  alias LunaConnect.Configuration

  @base_url "https://api.lunatask.app/v1"

  @connect_options [
    transport_opts: [cacertfile: Path.expand("./.cacerts/cacerts.pem")]
  ]

  def create_task(params, %Configuration{access_token: access_token}) do
    Req.post!(@base_url <> "/tasks",
      json: params,
      auth: {:bearer, access_token},
      connect_options: @connect_options
    )
  end
end
