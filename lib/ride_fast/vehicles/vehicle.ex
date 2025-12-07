defmodule RideFast.Vehicles.Vehicle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field :plate, :string
    field :model, :string
    field :color, :string
    field :seats, :integer
    field :active, :boolean, default: false

    belongs_to :driver, RideFast.Accounts.Driver

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:driver_id, :plate, :model, :color, :seats, :active])
    |> validate_required([:driver_id, :plate, :model, :color, :seats, :active])
    |> unique_constraint(:plate)
    |> foreign_key_constraint(:driver_id)
  end
end
