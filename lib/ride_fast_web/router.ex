defmodule RideFastWeb.Router do
  use RideFastWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug RideFast.AuthPipeline
  end

  pipeline :admin_check do
    plug RideFastWeb.Plugs.RequireAdmin
  end


  # rotas públicas

  scope "/api/v1", RideFastWeb do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login

    resources "/languages", LanguageController, only: [:index]
  end

  # rotas AUTH (JWT)

  scope "/api/v1", RideFastWeb do
    pipe_through [:api, :auth]


    resources "/users", UserController, only: [:show, :update, :delete]

    resources "/drivers", DriverController, only: [:index, :show, :update, :delete] do

      get "/profile", DriverProfileController, :show
      post "/profile", DriverProfileController, :create
      put "/profile", DriverProfileController, :update

      resources "/vehicles", VehicleController, only: [:index, :create, :delete]

      get "/languages", LanguageController, :index_driver
      post "/languages", LanguageController, :associate
      delete "/languages/:language_id", LanguageController, :disassociate

      get "/ratings", RatingController, :index_by_driver
    end

    resources "/vehicles", VehicleController, only: [:update, :delete]

    resources "/rides", RideController, only: [:create, :index, :show]

    post "/rides/:id/accept", RideController, :accept
    post "/rides/:id/start", RideController, :start
    post "/rides/:id/complete", RideController, :complete
    post "/rides/:id/cancel", RideController, :cancel
    post "/rides/:ride_id/ratings", RatingController, :create
  end

  # rotas admin-only

  scope "/api/v1", RideFastWeb do
    pipe_through [:api, :auth, :admin_check]

    resources "/users", UserController, only: [:index, :create, :delete]
    resources "/drivers", DriverController, only: [:show, :create, :delete]

    post "/users", UserController, :create
    post "/drivers", DriverController, :create
    post "/languages", LanguageController, :create

  end

  if Application.compile_env(:ride_fast, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
