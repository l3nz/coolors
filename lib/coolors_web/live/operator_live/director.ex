defmodule CoolorsWeb.OperatorLive.Director do
  require Logger
  alias Coolors.PageletSrv
  alias Mix.PubSub
  use CoolorsWeb, :live_view

  alias Coolors.Pagelets
  alias Coolors.Tools

  alias Phoenix.PubSub

  @impl true
  def mount(%{"id" => id} = params, session, socket) do
    IO.puts(Tools.ii({"MOUNT:", params, session}))

    PubSub.subscribe(Coolors.PubSub, Tools.pubsub_channel(id))

    url_pagelet = ~p"/pagelet/1234"

    qr = Tools.pagelet_qr(url_pagelet)
    pagelet_state = PageletSrv.getCurrentState(id)

    socket =
      socket
      |> assign(
        qr_svg: qr,
        pagelet_url: url_pagelet,
        pagelet_id: id
      )
      |> assign(pagelet_state)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({CoolorsWeb.OperatorLive.FormComponent, {:saved, operator}}, socket) do
    {:noreply, stream_insert(socket, :pagelets, operator)}
  end

  def handle_info({:pagelet_state, new_pagelet_state}, socket) do
    socket = assign(socket, new_pagelet_state)
    Logger.error("Pagelet: #{Tools.ii(socket.assigns)}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    operator = Pagelets.get_operator!(id)
    {:ok, _} = Pagelets.delete_operator(operator)

    {:noreply, stream_delete(socket, :pagelets, operator)}
  end

  def handle_event("new_color", %{"value" => _}, %{assigns: %{pagelet_id: id}} = socket) do
    colors = ~w(MistyRose Black Red Green Purple Yellow Olive)
    newColor = Enum.random(colors)

    PageletSrv.set_state_attribute(id, :ps_bg_color, newColor)

    {:noreply, socket}
  end
end
