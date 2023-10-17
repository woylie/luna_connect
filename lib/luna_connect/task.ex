defmodule LunaConnect.Task do
  @moduledoc """
  Defines the schema for a task as returned by the Lunatask API.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__.Source
  alias Ecto.UUID

  @type t :: %__MODULE__{
          id: UUID.t(),
          area_id: UUID.t(),
          goal_id: UUID.t(),
          status: status(),
          previous_status: status() | nil,
          estimate: integer | nil,
          priority: priority(),
          motivation: motivation(),
          eisenhower: eisenhower(),
          sources: map,
          scheduled_on: DateTime.t() | nil,
          completed_at: DateTime.t() | nil,
          created_at: DateTime.t(),
          updated_at: DateTime.t(),
          deleted_at: DateTime.t() | nil
        }

  @type status :: :later | :next | :started | :waiting | :completed
  @type priority :: :highest | :high | :normal | :low | :lowest
  @type motivation :: :must | :should | :want | :unknown
  @type eisenhower ::
          :urgent_and_important
          | :urgent_not_important
          | :important_not_urgent
          | :not_urgent_or_important
          | :uncategorized

  @type source :: %Source{
          source: String.t(),
          source_id: String.t()
        }

  @primary_key false

  embedded_schema do
    field :id, UUID
    field :area_id, UUID
    field :goal_id, UUID

    field :status, Ecto.Enum,
      values: [:later, :next, :started, :waiting, :completed],
      default: :later

    field :previous_status, Ecto.Enum,
      values: [:later, :next, :started, :waiting, :completed]

    field :estimate, :integer

    field :priority, Ecto.Enum,
      values: [highest: 2, high: 1, normal: 0, low: -1, lowest: -2],
      default: :normal

    field :motivation, Ecto.Enum,
      values: [:must, :should, :want, :unknown],
      default: :unknown

    field :eisenhower, Ecto.Enum,
      values: [
        urgent_and_important: 1,
        urgent_not_important: 2,
        important_not_urgent: 3,
        not_urgent_or_important: 4,
        uncategorized: 0
      ],
      default: :uncategorized

    field :scheduled_on, :utc_datetime
    field :completed_at, :utc_datetime
    field :created_at, :utc_datetime
    field :updated_at, :utc_datetime
    field :deleted_at, :utc_datetime

    embeds_many :sources, Source, primary_key: false do
      field :source, :string
      field :source_id, :string
    end
  end

  defp changeset(task \\ %__MODULE__{}, attrs) do
    task
    |> cast(attrs, [
      :id,
      :area_id,
      :goal_id,
      :status,
      :previous_status,
      :estimate,
      :priority,
      :motivation,
      :eisenhower,
      :scheduled_on,
      :completed_at,
      :created_at,
      :updated_at,
      :deleted_at
    ])
    |> cast_embed(:sources, with: &source_changeset/2)
  end

  defp source_changeset(source, attrs) do
    cast(source, attrs, [:source, :source_id])
  end

  def validate(attrs) do
    attrs
    |> changeset
    |> apply_action(:validate)
  end

  def validate!(attrs) do
    attrs
    |> changeset
    |> apply_action(:validate)
  end
end

defimpl Jason.Encoder, for: LunaConnect.Task do
  def encode(
        %LunaConnect.Task{eisenhower: eisenhower, priority: priority} = struct,
        opts
      ) do
    struct
    |> Map.put(:eisenhower, integer_value(:eisenhower, eisenhower))
    |> Map.put(:priority, integer_value(:priority, priority))
    |> Jason.Encode.map(opts)
  end

  defp integer_value(field, value) do
    LunaConnect.Task
    |> Ecto.Enum.mappings(field)
    |> Keyword.fetch!(value)
  end
end

defimpl Jason.Encoder, for: LunaConnect.Task.Source do
  def encode(value, opts) do
    Jason.Encode.map(value, opts)
  end
end
