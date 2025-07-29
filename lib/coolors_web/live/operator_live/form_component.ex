defmodule CoolorsWeb.OperatorLive.FormComponent do
  use CoolorsWeb, :live_component

  alias Coolors.Pagelets

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage operator records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="operator-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:owner]}
          type="text"
          label="Owner User ID (eg a81bc81b-dead-4e5d-abff-90865d1e13b1)"
        />
        <.input field={@form[:secret]} type="text" label="Secret" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Operator</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{operator: operator} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Pagelets.change_operator(operator))
     end)}
  end

  @impl true
  def handle_event("validate", %{"operator" => operator_params}, socket) do
    changeset = Pagelets.change_operator(socket.assigns.operator, operator_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"operator" => operator_params}, socket) do
    save_operator(socket, socket.assigns.action, operator_params)
  end

  defp save_operator(socket, :edit, operator_params) do
    case Pagelets.update_operator(socket.assigns.operator, operator_params) do
      {:ok, operator} ->
        notify_parent({:saved, operator})

        {:noreply,
         socket
         |> put_flash(:info, "Operator updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_operator(socket, :new, operator_params) do
    case Pagelets.create_operator(operator_params) do
      {:ok, operator} ->
        notify_parent({:saved, operator})

        {:noreply,
         socket
         |> put_flash(:info, "Operator created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
