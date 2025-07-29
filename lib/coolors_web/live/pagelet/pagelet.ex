defmodule CoolorsWeb.PageletLive.Pagelet do
  use CoolorsWeb, :live_view

  alias Coolors.Pagelets

  @impl true
  def mount(_params, _session, socket) do
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
