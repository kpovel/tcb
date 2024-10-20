defmodule TcbWeb.Router do
  use TcbWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TcbWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TcbWeb.Plugs.RemoveXFrameOptions
    plug TcbWeb.Plugs.Lang, "en"
  end

  pipeline :authorized_only do
    plug TcbWeb.Plugs.AuthorizedOnly
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

  scope "/chat", TcbWeb do
    pipe_through [:browser, :authorized_only]

    live_session :chat, layout: false, on_mount: [{TcbWeb.UserAuth, :assign_chat_user}] do
      live "/all", ChatLive
      live "/:chat_uuid", ChatRoomLive
    end
  end

  scope "/api", TcbWeb do
    pipe_through :authorized_api

    post "/public-chat-room/create", PublicChatController, :create
    get "/chat-owner/:uuid", PublicChatController, :chat_owner
    put "/public-chat-room/edit-hashtag", PublicChatController, :put_hashtags
    put "/public-chat-room/edit-description", PublicChatController, :put_description
  end

  scope "/api", TcbWeb do
    pipe_through :api
    # todo: unauthorized only plug

    post "/signup", AuthController, :signup
    post "/login", AuthController, :login
    put "/validate-email/:code", AuthController, :validate_email

    put "/forgot-password", AuthController, :forgot_password
    put "/forgot-password/:code", AuthController, :forgot_password_code

    post "/refresh/access-token", TokenController, :access_token
    # post "/refresh/refresh-token", TokenController, :refresh_token
  end

  scope "/api", TcbWeb do
    pipe_through :authorized_api
    get "/default-avatars", AvatarController, :default_avatars
    get "/user-image/:name", AvatarController, :avatar

    put "/user/default-avatar-with-onboarding/save", AvatarController, :put_default_avatar
    post "/user/avatar/upload", AvatarController, :put_avatar

    get "/hashtags-group/all-hashtags-locale", HashtagController, :index
    put "/user/hashtags-with-onboarding/save", HashtagController, :put_hashtags
  end

  scope "/api/user", TcbWeb do
    pipe_through :authorized_api

    get "/onboarding/get-user", UserController, :onboarding_data
    put "/user-about-with-onboarding/save", UserController, :put_user_about
    put "/onboarding/end", UserController, :end_onboarding
    put "/new-password/save", UserController, :new_password
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
