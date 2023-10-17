defmodule LunaConnect.Configuration do
  @moduledoc """
  Defines a Configuration struct and decode/encode functions.
  """

  @type t :: %__MODULE__{
          access_token: String.t(),
          github: %{
            default_area_id: String.t(),
            ignored_organizations: [String.t()]
          }
        }

  defstruct [:access_token, :github]

  @doc """
  Reads, parses and validates the configuration file.
  """
  @spec read_config() :: t()
  def read_config do
    config_path()
    |> File.read!()
    |> parse!()
    |> validate!()
  end

  defp config_path do
    "LUNA_CONNECT_CONFIG_PATH"
    |> System.get_env(default_folder())
    |> Path.join("config.yml")
  end

  defp default_folder do
    Path.expand("~/.config/luna_connect")
  end

  defp parse!(file) do
    YamlElixir.read_from_string!(file)
  end

  defp validate!(%{"access_token" => access_token, "github" => github}) do
    %__MODULE__{
      access_token: access_token,
      github: %{
        default_area_id: validate_area_id!(github),
        ignored_organizations: validate_ignored_organizations!(github)
      }
    }
  end

  defp validate_area_id!(%{"default_area_id" => area_id})
       when is_binary(area_id) do
    area_id
  end

  defp validate_ignored_organizations!(%{"ignored_organizations" => list})
       when is_list(list) do
    list
  end
end
