defmodule RideFastWeb.AuthController do
  use RideFastWeb, :controller

  alias RideFast.Accounts
  alias RideFast.Guardian

  action_fallback RideFastWeb.FallbackController

  # POST /api/v1/auth/register:

  def register(conn, %{"role" => role} = params) do
    case role do
      "user" ->
        with {:ok, user} <- Accounts.create_user(params) do
          conn
          |> put_status(:created)
          |> json(%{message: "Usuário criado com sucesso.", id: user.id, email: user.email})
        end

      "driver" ->
        with {:ok, driver} <- Accounts.create_driver(params) do
          conn
          |> put_status(:created)
          |> json(%{message: "Motorista criado com sucesso.", id: driver.id, email: driver.email})
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Categoria Inválida. Deve ser 'Usuário' ou 'Motorista'."})
    end
  end

  # POST /api/v1/auth/login:

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_email_password(email, password) do
      {:ok, resource} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(resource)

        conn
        |> put_status(:ok)
        |> json(%{
          token: token,
          user: %{
            id: resource.id,
            email: resource.email,
            role: Accounts.get_role(resource)
          }
        })

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Email ou senha inválidos."})
    end
  end
end
