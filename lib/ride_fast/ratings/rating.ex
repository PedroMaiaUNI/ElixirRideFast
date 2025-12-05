defmodule RideFast.Ratings.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :score, :integer
    field :comment, :string

    belongs_to :driver, RideFast.Accounts.Driver, foreign_key: :to_driver_id
    belongs_to :user, RideFast.Accounts.User, foreign_key: :from_user_id
    belongs_to :ride, RideFast.Rides.Ride, foreign_key: :ride_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:score, :comment, :to_driver_id, :from_user_id, :ride_id])
    |> validate_required([:score, :comment, :to_driver_id, :from_user_id])
    |> validate_inclusion(:score, 1..5)
  end
end
