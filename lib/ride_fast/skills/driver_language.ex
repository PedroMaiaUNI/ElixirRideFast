defmodule RideFast.Skills.DriversLanguage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "drivers_languages" do
    belongs_to :driver, RideFast.Accounts.Driver,
      foreign_key: :driver_id,
      type: :integer,
      primary_key: true

    belongs_to :language, RideFast.Skills.Language,
      foreign_key: :language_id,
      type: :integer,
      primary_key: true

    timestamps()
  end

  def changeset(drivers_language, attrs) do
    drivers_language
    |> cast(attrs, [:driver_id, :language_id])
    |> validate_required([:driver_id, :language_id])
  end
end
