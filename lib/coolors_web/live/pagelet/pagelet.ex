defmodule CoolorsWeb.PageletLive.Pagelet do
  use CoolorsWeb, :live_view

  alias Coolors.Pagelets

  @impl true
  def mount(_params, _session, socket) do
    # See https://hexdocs.pm/qr_code/readme.html
    {:ok, qr} =
      "https://www.loway.ch"
      |> QRCode.create(:high)
      |> QRCode.render()
      |> QRCode.to_base64()

    socket =
      socket
      |> assign(qr_svg: "data:image/svg+xml;base64,#{qr}")

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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    operator = Pagelets.get_operator!(id)
    {:ok, _} = Pagelets.delete_operator(operator)

    {:noreply, stream_delete(socket, :pagelets, operator)}
  end
end
