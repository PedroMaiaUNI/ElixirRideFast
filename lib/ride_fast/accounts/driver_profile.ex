defmodule RideFast.Accounts.DriverProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "driver_profiles" do
    @primary_key {:driver_id, :id, autogenerate: false}

    field :license_number, :string
    field :license_expiry, :date
    field :background_check_ok, :boolean, default: false
    field :driver_id, :id

    belongs_to :driver, RideFast.Accounts.Driver, define_field: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(driver_profile, attrs) do
    driver_profile
    |> cast(attrs, [:driver_id, :license_number, :license_expiry, :background_check_ok])
    |> validate_required([:license_number, :license_expiry, :background_check_ok])
  end
end
