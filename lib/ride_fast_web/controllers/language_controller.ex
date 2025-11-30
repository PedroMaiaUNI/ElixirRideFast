defmodule RideFastWeb.LanguageController do
  use RideFastWeb, :controller

  alias RideFast.Skills
  alias RideFast.Skills.Language

  action_fallback RideFastWeb.FallbackController

  def index(conn, _params) do
    languages = Skills.list_languages()
    render(conn, :index, languages: languages)
  end

  def create(conn, %{"language" => language_params}) do
    with {:ok, %Language{} = language} <- Skills.create_language(language_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/languages/#{language}")
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
end
