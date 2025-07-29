defmodule CoolorsWeb.PageletLive.Pagelet do
  use CoolorsWeb, :live_view

  alias Coolors.Pagelets
  alias Coolors.Tools
  alias Phoenix.PubSub
  alias Coolors.PageletSrv
  require Logger

  @impl true
  def mount(%{"id" => id} = params, session, socket) do
    PubSub.subscribe(Coolors.PubSub, Tools.pubsub_channel(id))

    IO.puts(Tools.ii({"MOUNT PAGELET:", params, session}))
    pagelet_state = PageletSrv.getCurrentState(id, true)

    socket =
      socket
      |> assign(
        qr_svg: "",
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
  def handle_info({:director_update, %{bg_color: bg_color}}, socket) do
    socket = assign(socket, bg_color: bg_color)
    {:noreply, socket}
  end

  def handle_info({:pagelet_state, new_pagelet_state}, socket) do
    socket = assign(socket, new_pagelet_state)
    Logger.warning("Pagelet #{Tools.ii(self())}: #{Tools.ii(new_pagelet_state)}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    operator = Pagelets.get_operator!(id)
    {:ok, _} = Pagelets.delete_operator(operator)

    {:noreply, stream_delete(socket, :pagelets, operator)}
  end
end
