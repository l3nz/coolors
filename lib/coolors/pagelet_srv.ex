defmodule Coolors.PageletSrv do
  use GenServer
  alias Coolors.Tools
  alias Coolors.Rooms
  alias Phoenix.PubSub

  def start_link(pagelet_name) do
    GenServer.start_link(__MODULE__, pagelet_name, name: {:global, pagelet_name})
  end

  @doc """
  Fa partire il GenServer se non esiste.
  """
  def getCurrentState(id) do
    pid = Rooms.pid_for_pagelet(id)

    GenServer.call(pid, :get_current_state)
  end

  def set_state_attribute(id, key, value) do
    pid = Rooms.pid_for_pagelet(id)

    GenServer.cast(pid, {:set_state_attribute, key, value})
  end

  @impl true
  def init(pagelet_id) do
    {:ok,
     %{
       pagelet_id: pagelet_id,
       created_on: "xxxx",
       pagelet_state: %{
         ps_bg_color: "black",
         ps_connected: false,
         ps_message: ""
       }
     }}
  end

  @impl true
  def handle_call(:get_current_state, _from, %{pagelet_state: pagelet_state} = state) do
    {:reply, pagelet_state, state}
  end

  @impl true
  def handle_cast(
        {:set_state_attribute, key, value},
        %{pagelet_id: id, pagelet_state: pagelet_state} = state
      ) do
    new_pagelet_state = Map.put(pagelet_state, key, value)

    channel = Tools.pubsub_channel(id)
    PubSub.broadcast(Coolors.PubSub, channel, {:pagelet_state, pagelet_state})

    {:noreply, %{state | pagelet_state: new_pagelet_state}}
  end
end
