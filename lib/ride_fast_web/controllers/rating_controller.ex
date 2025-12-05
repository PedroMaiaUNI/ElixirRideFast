defmodule RideFastWeb.RatingController do
  use RideFastWeb, :controller

  alias RideFast.Ratings
  alias RideFast.Ratings.Rating
  alias RideFast.Rides

  action_fallback RideFastWeb.FallbackController

  def index(conn, _params) do
    ratings = Ratings.list_ratings()
    render(conn, :index, ratings: ratings)
  end

  # GET /api/v1/drivers/:driver_id/ratings
  def index_by_driver(conn, %{"driver_id" => driver_id}) do
    ratings = RideFast.Ratings.list_ratings_by_driver(driver_id)
    render(conn, :index, ratings: ratings)
  end

  def get_current_user_id(conn) do
      # conn.assigns[:current_user].id
      conn.assigns[:user_id]
  end

  def create(conn, %{"ride_id" => ride_id} = params) do
    #   with {:ok, %Rating{} = rating} <- Ratings.create_rating(rating_params) do
    #   conn
    #   |> put_status(:created)
    #   |> put_resp_header("location", ~p"/api/ratings/#{rating}")
    #   |> render(:show, rating: rating)

    current_user = Guardian.Plug.current_resource(conn)

    ride = Rides.get_ride!(ride_id)

    if ride.status == "FINALIZADA" do
      rating_params =
          params
          |> Map.put("from_user_id", current_user.id)
          |> Map.put("to_driver_id", ride.driver_id)
          |> Map.put("ride_id", ride.id)

      with {:ok, %RideFast.Ratings.Rating{} = rating} <- Ratings.create_rating(rating_params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/v1/ratings/#{rating}")
        |> render(:show, rating: rating)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Avaliação só será disponível ao final da corrida."})
    end

  end

  def show(conn, %{"id" => id}) do
    rating = Ratings.get_rating!(id)
    render(conn, :show, rating: rating)
  end

  def update(conn, %{"id" => id} = rating_params) do
    rating = Ratings.get_rating!(id)

    with {:ok, %Rating{} = rating} <- Ratings.update_rating(rating, rating_params) do
      render(conn, :show, rating: rating)
    end
  end

  def delete(conn, %{"id" => id}) do
    rating = Ratings.get_rating!(id)

    with {:ok, %Rating{}} <- Ratings.delete_rating(rating) do
      send_resp(conn, :no_content, "")
    end
  end
end
