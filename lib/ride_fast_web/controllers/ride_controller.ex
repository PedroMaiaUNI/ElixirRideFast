defmodule RideFastWeb.RideController do
  use RideFastWeb, :controller

  alias RideFast.Rides
  alias RideFast.Rides.Ride

  action_fallback RideFastWeb.FallbackController

  def index(conn, _params) do
    rides = Rides.list_rides()
    render(conn, :index, rides: rides)
  end

  def create(conn, %{"ride" => ride_params}) do
    with {:ok, %Ride{} = ride} <- Rides.create_ride(ride_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/rides/#{ride}")
      |> render(:show, ride: ride)
    end
  end

  def show(conn, %{"id" => id}) do
    ride = Rides.get_ride!(id)
    render(conn, :show, ride: ride)
  end

  def update(conn, %{"id" => id, "ride" => ride_params}) do
    ride = Rides.get_ride!(id)

    with {:ok, %Ride{} = ride} <- Rides.update_ride(ride, ride_params) do
      render(conn, :show, ride: ride)
    end
  end

  def delete(conn, %{"id" => id}) do
    ride = Rides.get_ride!(id)

    with {:ok, %Ride{}} <- Rides.delete_ride(ride) do
      send_resp(conn, :no_content, "")
    end
  end

  # POST /api/v1/rides/:id/accept
  def accept(conn, %{"id" => id, "vehicle_id" => vehicle_id}) do
    driver = Guardian.Plug.current_resource(conn)
    ride = RideHailing.get_ride!(id)

    if RideFast.Accounts.get_role(driver) == "driver" do
      case RideHailing.accept_ride(ride, driver.id, vehicle_id) do
        {:ok, updated_ride} ->
          render(conn, :show, ride: updated_ride)

        {:error, reason} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: reason})
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Não é motorista!"})
    end
  end

  # POST /api/v1/rides/:id/start
  def start(conn, %{"id" => id}) do
    driver = Guardian.Plug.current_resource(conn)
    ride = RideHailing.get_ride!(id)

    case RideHailing.start_ride(ride, driver.id) do
      {:ok, updated_ride} ->
        render(conn, :show, ride: updated_ride)

      {:error, reason} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: reason})
    end
  end

  # POST /api/v1/rides/:id/complete
  def complete(conn, %{"id" => id, "final_price" => final_price}) do
    driver = Guardian.Plug.current_resource(conn)
    ride = RideHailing.get_ride!(id)

    case RideHailing.complete_ride(ride, driver.id, final_price) do
      {:ok, updated_ride} ->
        render(conn, :show, ride: updated_ride)

      {:error, reason} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: reason})
    end
  end
end
