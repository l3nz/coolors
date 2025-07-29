defmodule CoolorsWeb.OperatorLive.Index do
  use CoolorsWeb, :live_view

  alias Coolors.Pagelets
  alias Coolors.Pagelets.Operator

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :pagelets, Pagelets.list_pagelets())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Operator")
    |> assign(:operator, Pagelets.get_operator!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Operator")
    |> assign(:operator, %Operator{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pagelets")
    |> assign(:operator, nil)
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
