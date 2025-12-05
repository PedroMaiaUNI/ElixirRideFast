defmodule RideFastWeb.VehicleController do
  use RideFastWeb, :controller

  alias RideFast.Vehicles
  alias RideFast.Vehicles.Vehicle

  action_fallback RideFastWeb.FallbackController

  def index(conn, %{"driver_id" => driver_id}) do
    vehicles = Vehicles.list_vehicles_by_driver(driver_id) # GET /api/v1/drivers/:driver_id/vehicles
    render(conn, :index, vehicles: vehicles)
  end

  # POST /api/v1/drivers/:driver_id/vehicles
  def create(conn, %{"driver_id" => driver_id} = params) do
    vehicle_params = Map.put(params, "driver_id", driver_id)

    case RideFast.Vehicles.create_vehicle(vehicle_params) do
        {:ok, vehicle} ->
            conn
            |> put_status(:created)
            |> render(:show, vehicle: vehicle)
        {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(RideFastWeb.ErrorJSON, :error, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    vehicle = Vehicles.get_vehicle!(id)
    render(conn, :show, vehicle: vehicle)
  end

  def update(conn, %{"id" => id} = vehicle_params) do
    vehicle = Vehicles.get_vehicle!(id)

    with {:ok, %Vehicle{} = vehicle} <- Vehicles.update_vehicle(vehicle, vehicle_params) do
      render(conn, :show, vehicle: vehicle)
    end
  end

  def delete(conn, %{"id" => id}) do
    vehicle = Vehicles.get_vehicle!(id)

    with {:ok, %Vehicle{}} <- Vehicles.delete_vehicle(vehicle) do
      send_resp(conn, :no_content, "")
    end
  end
end
