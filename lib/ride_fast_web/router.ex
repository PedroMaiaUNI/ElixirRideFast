defmodule RideFastWeb.Router do
  use RideFastWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RideFastWeb do
    pipe_through :api

    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login

    resources "/rides", RideController, except: [:new, :edit]
    resources "/ratings", RatingController, except: [:new, :edit]
  end

  scope "/api/v1", RideFastWeb do
    pipe_through :api

    #ROTAS PÚBLICAS
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
  end

  scope "/api/v1", RideFastWeb do
    pipe_through [:api, RideFast.AuthPipeline]

    #ROTAS PRIVADAS (JWT)

    resources "/users", UserController, except: [:new, :edit]

    resources "/drivers", DriverController, except: [:new, :edit] do
      # /api/v1/drivers/:driver_id/vehicles
      resources "/vehicles", VehicleController, only: [:index, :create]
      get "/profile", DriverProfileController, :show
      post "/profile", DriverProfileController, :create
      put "/profile", DriverProfileController, :update
    end

    resources "/vehicles", VehicleController, only: [:update, :delete]

    resources "/rides", RideController, except: [:new, :edit]
    post "/rides/:id/accept", RideController, :accept
    post "/rides/:id/start", RideController, :start
    post "/rides/:id/complete", RideController, :complete


    resources "/ratings", RatingController, except: [:new, :edit]
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:ride_fast, :dev_routes) do

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
