defmodule CoolorsWeb.Router do
  use CoolorsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CoolorsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CoolorsWeb do
    pipe_through :browser

    get "/", PageController, :home
    #
    # Editor
    #

    live "/operator/pagelets/director/:id", OperatorLive.Director, :director

    live "/operator/pagelets", OperatorLive.Index, :index
    live "/operator/pagelets/new", OperatorLive.Index, :new
    live "/operator/pagelets/:id/edit", OperatorLive.Index, :edit

    live "/operator/pagelets/:id", OperatorLive.Show, :show
    live "/operator/pagelets/:id/show/edit", OperatorLive.Show, :edit

    #
    # Pagelet
    #
    live "/pagelet/:id", PageletLive.Pagelet, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CoolorsWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:coolors, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CoolorsWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
