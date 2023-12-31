defmodule LunaConnect.Configuration do
  @moduledoc """
  Defines a Configuration struct and decode/encode functions.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__.Github
  alias __MODULE__.Linear

  @type t :: %__MODULE__{
          access_token: String.t(),
          github: %Github{},
          linear: %Linear{}
        }

  @type github :: %Github{
          default_area_id: String.t(),
          ignored_organizations: [String.t()]
        }

  @type linear :: %Linear{
          api_key: String.t() | nil,
          default_area_id: String.t()
        }

  @primary_key false

  embedded_schema do
    field :access_token, :string

    embeds_one :github, Github, primary_key: false do
      field :default_area_id, :string
      field :ignored_organizations, {:array, :string}, default: []
    end

    embeds_one :linear, Linear, primary_key: false do
      field :api_key, :string
      field :default_area_id, :string
    end
  end

  defp changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:access_token])
    |> validate_required([:access_token])
    |> cast_embed(:github, required: true, with: &github_changeset/2)
    |> cast_embed(:linear, required: true, with: &linear_changeset/2)
  end

  defp github_changeset(github, attrs) do
    github
    |> cast(attrs, [:default_area_id, :ignored_organizations])
    |> validate_required([:default_area_id])
  end

  defp linear_changeset(linear, attrs) do
    cast(linear, attrs, [:api_key, :default_area_id])
  end

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

  defp validate!(%{} = attrs) do
    attrs
    |> changeset
    |> apply_action!(:validate)
  end
end
