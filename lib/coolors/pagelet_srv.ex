defmodule Coolors.PageletSrv do
  use GenServer
  alias Coolors.Tools
  alias Coolors.Rooms
  alias Phoenix.PubSub
  require Logger

  def start_link(pagelet_name) do
    GenServer.start_link(__MODULE__, pagelet_name, name: {:global, pagelet_name})
  end

  @doc """
  Fa partire il GenServer se non esiste.
  """
  def getCurrentState(id, pagelet?) do
    pid = Rooms.pid_for_pagelet(id)

    subscriber =
      if pagelet? do
        :pagelet
      else
        :director
      end

    GenServer.call(pid, {:get_current_state, subscriber, self()})
  end

  def setStateAttribute(id, key, value) do
    pid = Rooms.pid_for_pagelet(id)

    GenServer.cast(pid, {:set_state_attribute, key, value})
  end

  def refreshSubscribers(id) do
    pid = Rooms.pid_for_pagelet(id)

    GenServer.cast(pid, {:refresh_subscriber_pids})
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
       },
       connected_clients: %{},
       connected_directors: %{}
     }}
  end

  @impl true
  def handle_call(
        {:get_current_state, client_type, subscriberPid},
        _from,
        %{
          pagelet_state: pagelet_state,
          connected_clients: connected_clients,
          connected_directors: connected_directors
        } = state
      ) do
    {new_connected_clients, new_connected_directors} =
      case client_type do
        :pagelet -> {monitor_pagelets(subscriberPid, connected_clients), connected_directors}
        :director -> {connected_clients, monitor_pagelets(subscriberPid, connected_directors)}
      end

    Logger.warning(
      "Active clients: #{map_size(new_connected_clients)} - dirs: #{map_size(new_connected_directors)}"
    )

    new_state = %{
      state
      | connected_clients: new_connected_clients,
        connected_directors: new_connected_directors
    }

    update_connected(new_state)

    {:reply, pagelet_state, new_state}
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

  def handle_cast(
        {:refresh_subscriber_pids},
        %{connected_clients: connected_clients, connected_directors: connected_directors} = state
      ) do
    new_connected_clients = check_pids(connected_clients)
    new_connected_directors = check_pids(connected_directors)

    new_state = %{
      state
      | connected_clients: new_connected_clients,
        connected_directors: new_connected_directors
    }

    update_connected(new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(
        {:DOWN, _monitor_ref, :process, pid, reason},
        %{connected_clients: connected_clients, connected_directors: connected_directors} = state
      ) do
    Logger.warning("Monitored PID #{inspect(pid)} died with reason: #{inspect(reason)}")

    new_state =
      if Map.has_key?(connected_clients, pid) do
        new_connected_clients = Map.delete(connected_clients, pid)

        Logger.warning("Remaining clients: #{map_size(new_connected_clients)}")

        %{state | connected_clients: new_connected_clients}
      else
        new_connected_directors = Map.delete(connected_directors, pid)

        Logger.warning("Remaining directors: #{map_size(new_connected_directors)}")

        %{state | connected_directors: new_connected_directors}
      end

    update_connected(new_state)
    {:noreply, new_state}
  end

  def monitor_pagelets(pid, connected_clients) do
    case Map.get(connected_clients, pid, :none) do
      :none ->
        with _ = Process.monitor(pid) do
          Map.put(connected_clients, pid, Tools.now())
        end

      _ ->
        connected_clients
    end
  end

  def update_connected(%{
        connected_clients: connected_clients,
        connected_directors: connected_directors
      }) do
    msg =
      {:now_connected,
       %{directors: Map.keys(connected_directors), clients: Map.keys(connected_clients)}}

    for d <- Map.keys(connected_directors) do
      send(d, msg)
    end
  end

  @doc """
  Scoppia se i processi sono REMOTI - da ripensare.
  """
  def check_pids(mPids) do
    values =
      for {pid, _} = v <- Map.to_list(mPids) do
        if Process.alive?(pid) do
          v
        else
          nil
        end
      end

    mNewPids =
      values
      |> Enum.filter(fn kv -> kv != nil end)
      |> Map.new()

    Logger.warning("Original pids: #{Tools.ii(mPids)} -> #{Tools.ii(mNewPids)}")

    mNewPids
  end
end
