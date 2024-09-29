defmodule TcbWeb.Router do
  use TcbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TcbWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TcbWeb.Plugs.Lang, "en"
  end

  pipeline :authorized_api do
    plug :accepts, ["json"]
    plug TcbWeb.Plugs.Lang, "en"
    plug TcbWeb.Plugs.AuthorizedOnly
  end

  scope "/", TcbWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", TcbWeb do
    pipe_through :api
    # todo: unauthorized only plug

    post "/signup", AuthController, :signup
    put "/validate-email/:code", AuthController, :validate_email

    post "/refresh/access-token", TokenController, :access_token
    # post "/refresh/refresh-token", TokenController, :refresh_token
  end

  scope "/api", TcbWeb do
    pipe_through :authorized_api
    get "/default-avatars", AvatarController, :default_avatars
    get "/user-image/:name", AvatarController, :avatar

    put "/user/default-avatar-with-onboarding/save", AvatarController, :put_default_avatar
  end

  scope "/api/user", TcbWeb do
    pipe_through :authorized_api

    get "/onboarding/get-user", UserController, :onboarding_data
    put "/user-about-with-onboarding/save", UserController, :put_user_about
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tcb, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TcbWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
