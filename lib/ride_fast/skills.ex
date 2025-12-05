defmodule RideFast.Skills do
  @moduledoc """
  The Skills context.
  """

  import Ecto.Query, warn: false
  alias RideFast.Repo

  alias RideFast.Skills.Language
  alias RideFast.Skills.DriversLanguage

  @doc """
  Returns the list of languages.

  ## Examples

      iex> list_languages()
      [%Language{}, ...]

  """
  def list_languages do
    Repo.all(Language)
  end

  @doc """
  Gets a single language.

  Raises `Ecto.NoResultsError` if the Language does not exist.

  ## Examples

      iex> get_language!(123)
      %Language{}

      iex> get_language!(456)
      ** (Ecto.NoResultsError)

  """
  def get_language!(id), do: Repo.get!(Language, id)

  @doc """
  Creates a language.

  ## Examples

      iex> create_language(%{field: value})
      {:ok, %Language{}}

      iex> create_language(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_language(attrs) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a language.

  ## Examples

      iex> update_language(language, %{field: new_value})
      {:ok, %Language{}}

      iex> update_language(language, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_language(%Language{} = language, attrs) do
    language
    |> Language.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a language.

  ## Examples

      iex> delete_language(language)
      {:ok, %Language{}}

      iex> delete_language(language)
      {:error, %Ecto.Changeset{}}

  """
  def delete_language(%Language{} = language) do
    Repo.delete(language)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking language changes.

  ## Examples

      iex> change_language(language)
      %Ecto.Changeset{data: %Language{}}

  """
  def change_language(%Language{} = language, attrs \\ %{}) do
    Language.changeset(language, attrs)
  end

  # POST /api/v1/drivers/{driver_id}/languages/{language_id}
  def associate_language(attrs) do
    %DriversLanguage{}
    |> DriversLanguage.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  # DELETE /api/v1/drivers/{driver_id}/languages/{language_id}
  def disassociate_language(driver_id, language_id) do
    DriversLanguage
    |> Repo.get_by(driver_id: driver_id, language_id: language_id)
    |> case do
      nil -> {:error, :not_found}
      dl -> Repo.delete(dl)
    end
  end

  def list_driver_languages(driver_id) do
    DriversLanguage
    |> join(:inner, [dl], l in assoc(dl, :language))
    |> where([dl, l], dl.driver_id == ^driver_id)
    |> select([dl, l], l)
    |> Repo.all()
  end

end
