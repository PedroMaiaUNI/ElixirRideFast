defmodule RideFastWeb.DriverProfileController do
  use RideFastWeb, :controller

  alias RideFast.Accounts
  alias RideFast.Accounts.DriverProfile

  action_fallback RideFastWeb.FallbackController

  def index(conn, _params) do
    driver_profiles = Accounts.list_driver_profiles()
    render(conn, :index, driver_profiles: driver_profiles)
  end

  def create(conn, %{"driver_id" => driver_id} = params) do
    full_params = Map.put(params, "driver_id", driver_id) # POST /api/v1/drivers/:driver_id/profile

    with {:ok, %DriverProfile{} = profile} <- Accounts.create_driver_profile(full_params) do
      conn
      |> put_status(:created)
      |> json(%{
        driver_id: profile.driver_id,
        license_number: profile.license_number,
        background_check_ok: profile.background_check_ok
      })
    end
  end

  def show(conn, %{"driver_id" => driver_id}) do
    # driver_profile = Accounts.get_driver_profile!(id)
    # render(conn, :show, driver_profile: driver_profile)

    profile = Accounts.get_driver_profile_by_driver_id(driver_id)

    if profile do
      json(conn, %{
        driver_id: profile.driver_id,
        license_number: profile.license_number,
        license_expiry: profile.license_expiry,
        background_check_ok: profile.background_check_ok
      })
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Perfil não encontrado."})
    end
  end

  def update(conn, %{"driver_id" => id} = driver_profile_params) do
    driver_profile = Accounts.get_driver_profile!(id)

    profile = Accounts.get_driver_profile_by_driver_id(id)

    if profile do
      with {:ok, %DriverProfile{} = updated_profile} <- Accounts.update_driver_profile(profile, driver_profile_params) do
        json(conn, %{
          driver_id: updated_profile.driver_id,
          license_number: updated_profile.license_number,
          license_expiry: updated_profile.license_expiry,
          background_check_ok: updated_profile.background_check_ok
        })
      end
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Perfil não encontrado"})
    end
  end

  def delete(conn, %{"id" => id}) do
    driver_profile = Accounts.get_driver_profile!(id)

    with {:ok, %DriverProfile{}} <- Accounts.delete_driver_profile(driver_profile) do
      send_resp(conn, :no_content, "")
    end
  end
end
