defmodule CoolorsWeb.OperatorLive.Director do
  require Logger
  alias Coolors.PageletSrv
  alias Mix.PubSub
  use CoolorsWeb, :live_view

  alias Coolors.Pagelets
  alias Coolors.Tools

  alias Phoenix.PubSub

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    Logger.warning("MOUNTING page #{id} as #{Tools.ii(self())}")

    # "https://34d0f6fab5ce.ngrok-free.app"
    external_uri = "http://127.0.0.1:4000"
    url_pagelet = external_uri <> ~p"/pagelet/1234"
    # uri = %URI{
    #  scheme: Atom.to_string(conn.scheme),
    #  host: conn.host,
    #  port: conn.port,
    #  path: conn.request_path,
    #  query: conn.query_string
    # }
    # uri_url = URI.to_string(uri)

    qr = Tools.pagelet_qr(url_pagelet)

    pagelet_state =
      if connected?(socket) do
        Logger.warning("MOUNTING page is connected")
        PubSub.subscribe(Coolors.PubSub, Tools.pubsub_channel(id))
        PageletSrv.getCurrentState(id, false)
      else
        PageletSrv.default_state()
      end

    socket =
      socket
      |> assign(
        qr_svg: qr,
        pagelet_url: url_pagelet,
        pagelet_id: id,
        connected_clients: [],
        connected_directors: []
      )
      |> assign(pagelet_state)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true

  def handle_info({:pagelet_state, new_pagelet_state}, socket) do
    socket = assign(socket, new_pagelet_state)
    Logger.warning("Director #{Tools.ii(self())}: #{Tools.ii(new_pagelet_state)}")

    {:noreply, socket}
  end

  def handle_info(
        {:now_connected, %{directors: connected_directors, clients: connected_clients}},
        socket
      ) do
    socket =
      assign(socket,
        connected_clients: connected_clients,
        connected_directors: connected_directors
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    operator = Pagelets.get_operator!(id)
    {:ok, _} = Pagelets.delete_operator(operator)

    {:noreply, stream_delete(socket, :pagelets, operator)}
  end

  def handle_event(
        "msg-changed",
        %{"value" => newMessage},
        %{assigns: %{pagelet_id: id}} = socket
      ) do
    PageletSrv.setStateAttribute(id, :ps_message, newMessage)

    {:noreply, socket}
  end

  def handle_event("new_color", %{"value" => _}, %{assigns: %{pagelet_id: id}} = socket) do
    Logger.warning("Event new color")
    colors = ~w(MistyRose Black Red Green Purple Yellow Olive)
    newColor = Enum.random(colors)

    PageletSrv.setStateAttribute(id, :ps_bg_color, newColor)

    {:noreply, socket}
  end
end
