defmodule RideFast.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :ride_fast,
    module: RideFast.Guardian,
    error_handler: RideFastWeb.AuthErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
