defmodule RideFast.Rides do
  @moduledoc """
  The Rides context.
  """

  import Ecto.Query, warn: false
  alias RideFast.Repo

  alias RideFast.Rides.Ride

  @doc """
  Returns the list of rides.

  ## Examples

      iex> list_rides()
      [%Ride{}, ...]

  """
  def list_rides do
    Repo.all(Ride)
  end

  @doc """
  Gets a single ride.

  Raises `Ecto.NoResultsError` if the Ride does not exist.

  ## Examples

      iex> get_ride!(123)
      %Ride{}

      iex> get_ride!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ride!(id), do: Repo.get!(Ride, id)

  @doc """
  Creates a ride.

  ## Examples

      iex> create_ride(%{field: value})
      {:ok, %Ride{}}

      iex> create_ride(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ride(attrs) do
    %Ride{}
    |> Ride.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ride.

  ## Examples

      iex> update_ride(ride, %{field: new_value})
      {:ok, %Ride{}}

      iex> update_ride(ride, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ride(%Ride{} = ride, attrs) do
    ride
    |> Ride.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ride.

  ## Examples

      iex> delete_ride(ride)
      {:ok, %Ride{}}

      iex> delete_ride(ride)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ride(%Ride{} = ride) do
    Repo.delete(ride)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ride changes.

  ## Examples

      iex> change_ride(ride)
      %Ecto.Changeset{data: %Ride{}}

  """
  def change_ride(%Ride{} = ride, attrs \\ %{}) do
    Ride.changeset(ride, attrs)
  end


  def get_ride_with_lock!(id) do
    Repo.get!(Ride, id) |> Repo.preload([:user, :driver, :vehicle])
  end

  def accept_ride(%Ride{id: id}, driver_id, vehicle_id) do
    Repo.transaction(fn ->
      ride = Repo.query!("SELECT * FROM rides WHERE id = ? FOR UPDATE", [id])

      ride = Repo.get!(Ride, id)

      if ride.status == "SOLICITADA" do
        attrs = %{
          status: "ACEITA",
          driver_id: driver_id,
          vehicle_id: vehicle_id
        }

        ride
        |> Ride.changeset(attrs)
        |> Repo.update!()
      else
        Repo.rollback("Corrida não está disponível (Status: #{ride.status})")
      end
    end)
  end

  def start_ride(%Ride{} = ride, driver_id) do
    cond do
      ride.status != "ACEITA" ->
        {:error, "Status deve ser ACEITA para começar corrida"}

      ride.driver_id != driver_id ->
        {:error, "Não é motorista!"}

      true ->
        ride
        |> Ride.changeset(%{
          status: "EM_ANDAMENTO",
          started_at: NaiveDateTime.local_now()
        })
        |> Repo.update()
    end
  end

  def complete_ride(%Ride{} = ride, driver_id, final_price) do
    cond do
      ride.status != "EM_ANDAMENTO" ->
        {:error, "Corrida deve estar EM ANDAMENTO para ser terminada"}

      ride.driver_id != driver_id ->
        {:error, "Não é motorista!"}

      true ->
        ride
        |> Ride.changeset(%{
          status: "FINALIZADA",
          ended_at: NaiveDateTime.local_now(),
          final_price: final_price
        })
        |> Repo.update()
    end
  end

  def cancel_ride(%Ride{} = ride) do
    if ride.status in ["SOLICITADA", "ACEITA", "EM_ANDAMENTO"] do
      ride
      |> Ride.changeset(%{status: "CANCELADA"})
      |> Repo.update()
    else
      {:error, "Não é possível cancelar uma corrida já terminada."}
    end
  end
end
