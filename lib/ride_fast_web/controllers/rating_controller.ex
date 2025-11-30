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

  def create(conn, %{"rating" => rating_params}) do
    #   with {:ok, %Rating{} = rating} <- Ratings.create_rating(rating_params) do
    #   conn
    #   |> put_status(:created)
    #   |> put_resp_header("location", ~p"/api/ratings/#{rating}")
    #   |> render(:show, rating: rating)

    ride_id = rating_params["ride_id"]

    ride = Rides.get_ride!(ride_id)

    if ride.status == "FINALIZADA" do
      with {:ok, %Rating{} = rating} <- Social.create_rating(rating_params) do
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

  def update(conn, %{"id" => id, "rating" => rating_params}) do
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
