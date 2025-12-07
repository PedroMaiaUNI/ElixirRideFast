defmodule RideFast.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RideFast.Repo

  alias RideFast.Accounts.User

  alias RideFast.Accounts.{User, Driver}
  alias RideFast.Accounts.DriverProfile

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias RideFast.Accounts.Driver

  @doc """
  Returns the list of drivers.

  ## Examples

      iex> list_drivers()
      [%Driver{}, ...]

  """
  def list_drivers do
    Repo.all(Driver)
  end

  @doc """
  Gets a single driver.

  Raises `Ecto.NoResultsError` if the Driver does not exist.

  ## Examples

      iex> get_driver!(123)
      %Driver{}

      iex> get_driver!(456)
      ** (Ecto.NoResultsError)

  """
  def get_driver!(id), do: Repo.get!(Driver, id)

  @doc """
  Creates a driver.

  ## Examples

      iex> create_driver(%{field: value})
      {:ok, %Driver{}}

      iex> create_driver(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_driver(attrs) do
    %Driver{}
    |> Driver.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a driver.

  ## Examples

      iex> update_driver(driver, %{field: new_value})
      {:ok, %Driver{}}

      iex> update_driver(driver, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_driver(%Driver{} = driver, attrs) do
    driver
    |> Driver.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a driver.

  ## Examples

      iex> delete_driver(driver)
      {:ok, %Driver{}}

      iex> delete_driver(driver)
      {:error, %Ecto.Changeset{}}

  """
  def delete_driver(%Driver{} = driver) do
    Repo.delete(driver)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking driver changes.

  ## Examples

      iex> change_driver(driver)
      %Ecto.Changeset{data: %Driver{}}

  """
  def change_driver(%Driver{} = driver, attrs \\ %{}) do
    Driver.changeset(driver, attrs)
  end

  alias RideFast.Accounts.DriverProfile

  @doc """
  Returns the list of driver_profiles.

  ## Examples

      iex> list_driver_profiles()
      [%DriverProfile{}, ...]

  """
  def list_driver_profiles do
    Repo.all(DriverProfile)
  end

  @doc """
  Gets a single driver_profile.

  Raises `Ecto.NoResultsError` if the Driver profile does not exist.

  ## Examples

      iex> get_driver_profile!(123)
      %DriverProfile{}

      iex> get_driver_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_driver_profile!(id), do: Repo.get!(DriverProfile, id)

  @doc """
  Creates a driver_profile.

  ## Examples

      iex> create_driver_profile(%{field: value})
      {:ok, %DriverProfile{}}

      iex> create_driver_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_driver_profile(attrs) do
    %DriverProfile{}
    |> DriverProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a driver_profile.

  ## Examples

      iex> update_driver_profile(driver_profile, %{field: new_value})
      {:ok, %DriverProfile{}}

      iex> update_driver_profile(driver_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_driver_profile(%DriverProfile{} = driver_profile, attrs) do
    driver_profile
    |> DriverProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a driver_profile.

  ## Examples

      iex> delete_driver_profile(driver_profile)
      {:ok, %DriverProfile{}}

      iex> delete_driver_profile(driver_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_driver_profile(%DriverProfile{} = driver_profile) do
    Repo.delete(driver_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking driver_profile changes.

  ## Examples

      iex> change_driver_profile(driver_profile)
      %Ecto.Changeset{data: %DriverProfile{}}

  """
  def change_driver_profile(%DriverProfile{} = driver_profile, attrs \\ %{}) do
    DriverProfile.changeset(driver_profile, attrs)
  end

  def authenticate_email_password(email, password) do
    user = Repo.get_by(User, email: email)
    driver = Repo.get_by(Driver, email: email)

    cond do
      user && Bcrypt.verify_pass(password, user.password_hash) ->
        {:ok, user}

      driver && Bcrypt.verify_pass(password, driver.password_hash) ->
        {:ok, driver}

      true ->
        {:error, :unauthorized}
    end
  end

  def get_role(%User{}), do: "user"
  def get_role(%Driver{}), do: "driver"

  def get_driver_profile_by_driver_id(driver_id) do
    Repo.get_by(DriverProfile, driver_id: driver_id)
  end

  def get_driver_with_associations!(id) do
    Driver
    |> Repo.get!(id)
    |> Repo.preload([:driver_profile, :vehicles, :languages])
  end

end
