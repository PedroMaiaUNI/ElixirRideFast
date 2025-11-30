defmodule RideFast.RidesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RideFast.Rides` context.
  """

  @doc """
  Generate a ride.
  """
  def ride_fixture(attrs \\ %{}) do
    {:ok, ride} =
      attrs
      |> Enum.into(%{
        dest_lat: 120.5,
        dest_lng: 120.5,
        ended_at: ~N[2025-11-25 18:31:00],
        final_price: "120.5",
        origin_lat: 120.5,
        origin_lng: 120.5,
        price_estimate: "120.5",
        requested_at: ~N[2025-11-25 18:31:00],
        started_at: ~N[2025-11-25 18:31:00],
        status: "some status"
      })
      |> RideFast.Rides.create_ride()

    ride
  end
end
