defmodule LunaConnect.Configuration do
  @moduledoc """
  Defines a Configuration struct and decode/encode functions.
  """

  @type t :: %__MODULE__{
          ignored_organizations: [String.t()]
        }

  defstruct ignored_organizations: []

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

  defp validate!(map) do
    %__MODULE__{
      ignored_organizations: validate_ignored_organizations!(map)
    }
  end

  defp validate_ignored_organizations!(%{"ignored_organizations" => list})
       when is_list(list) do
    list
  end
end
