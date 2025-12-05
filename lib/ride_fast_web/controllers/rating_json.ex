defmodule RideFastWeb.RatingJSON do
  alias RideFast.Ratings.Rating

  @doc """
  Renders a list of ratings.
  """
  def index(%{ratings: ratings}) do
    %{data: for(rating <- ratings, do: data(rating))}
  end

  @doc """
  Renders a single rating.
  """
  def show(%{rating: rating}) do
    %{data: data(rating)}
  end

  defp data(%Rating{} = rating) do
    %{
      id: rating.id,
      score: rating.score,
      comment: rating.comment,
      #teste, remover depois:
      to_driver_id: rating.to_driver_id,
      from_user_id: rating.from_user_id,
      ride_id: rating.ride_id
    }
  end
end
