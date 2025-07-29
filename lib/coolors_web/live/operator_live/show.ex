defmodule CoolorsWeb.OperatorLive.Show do
  use CoolorsWeb, :live_view

  alias Coolors.Pagelets

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:operator, Pagelets.get_operator!(id))}
  end

  defp page_title(:show), do: "Show Operator"
  defp page_title(:edit), do: "Edit Operator"
end
