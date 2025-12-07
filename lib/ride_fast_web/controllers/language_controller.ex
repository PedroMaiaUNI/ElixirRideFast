defmodule RideFastWeb.LanguageController do
  use RideFastWeb, :controller

  alias RideFast.Skills
  alias RideFast.Skills.Language

  action_fallback RideFastWeb.FallbackController

  def index(conn, _params) do
    languages = Skills.list_languages()
    render(conn, :index, languages: languages)
  end

  # POST /api/v1/languages
  def create(conn, params) when is_map(params) do
    with {:ok, %Language{} = language} <- Skills.create_language(params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/languages/#{language}")
      |> render(:show, language: language)
    end
  end

  def show(conn, %{"id" => id}) do
    language = Skills.get_language!(id)
    render(conn, :show, language: language)
  end

  def update(conn, %{"id" => id, "language" => language_params}) do
    language = Skills.get_language!(id)

    with {:ok, %Language{} = language} <- Skills.update_language(language, language_params) do
      render(conn, :show, language: language)
    end
  end

  def delete(conn, %{"id" => id}) do
    language = Skills.get_language!(id)

    with {:ok, %Language{}} <- Skills.delete_language(language) do
      send_resp(conn, :no_content, "")
    end
  end

  # POST /api/v1/drivers/:driver_id/languages
  def associate(conn, %{"driver_id" => driver_id} = driver_params) do
    params = %{
        "driver_id" => driver_id,
        "language_id" => driver_params["language_id"]
    }

    case Skills.associate_language(params) do
      {:ok, _dl} ->
        conn
        |> put_status(:created)
        |> json(%{message: "Idioma associado com sucesso."})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(RideFastWeb.ErrorJSON, :error, changeset: changeset)

      {:error, _} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "Falha ao associar idioma. Verifique se esse idioma já foi adicionado."})
    end
  end

  # GET /api/v1/drivers/:driver_id/languages
  def index_driver(conn, %{"driver_id" => driver_id}) do
    languages = Skills.list_driver_languages(driver_id)
    render(conn, :index, languages: languages)
  end

  # DELETE /api/v1/drivers/:driver_id/languages/:language_id
  def disassociate(conn, %{"driver_id" => driver_id, "language_id" => language_id}) do
    case Skills.disassociate_language(driver_id, language_id) do
      {:ok, _dl} ->
        send_resp(conn, :no_content, "")
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Associação não encontrada."})
      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Falha ao desassociar idioma."})
    end
  end
end
