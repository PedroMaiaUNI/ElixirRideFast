defmodule RideFastWeb.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]
  alias RideFast.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    current_resource = Guardian.Plug.current_resource(conn)

    if is_admin?(current_resource) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Acesso negado. Apenas para ADMIN."})
      |> halt()
    end
  end

  defp is_admin?(%Accounts.User{email: email}), do: String.contains?(email, "admin")
  defp is_admin?(_), do: false
end
