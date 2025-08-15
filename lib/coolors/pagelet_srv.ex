defmodule Coolors.PageletSrv do
  use GenServer
  alias Coolors.Tools
  alias Coolors.Rooms
  alias Coolors.PageletProcess
  alias Phoenix.PubSub
  require Logger

  @type connected_entities :: %{pid() => %PageletProcess{}}

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

  def default_state(),
    do: %{
      ps_bg_color: "black",
      ps_connected: false,
      ps_message: ""
    }

  @impl true
  def init(pagelet_id) do
    {:ok,
     %{
       pagelet_id: pagelet_id,
       created_on: Tools.now(),
       pagelet_state: default_state(),
       connected_clients: %{}
     }}
  end

  @impl true
  def handle_call(
        {:get_current_state, client_type, subscriberPid},
        _from,
        %{
          pagelet_state: pagelet_state,
          connected_clients: connected_clients
        } = state
      ) do
    new_connected_clients =
      monitor_pagelets(
        subscriberPid,
        client_type,
        connected_clients
      )

    Logger.warning("All active clients: #{map_size(new_connected_clients)}")

    new_state = %{
      state
      | connected_clients: new_connected_clients
    }

    update_connected(new_state)

    {:reply, pagelet_state, new_state}
  end

  @impl true
  def handle_cast(
        {:set_state_attribute, key, value},
        %{pagelet_id: id, pagelet_state: pagelet_state} = state
      ) do
    Logger.error("Set state attribute for id #{id}: #{key}=#{value}")

    new_pagelet_state = Map.put(pagelet_state, key, value)

    channel = Tools.pubsub_channel(id)
    PubSub.broadcast(Coolors.PubSub, channel, {:pagelet_state, new_pagelet_state})

    {:noreply, %{state | pagelet_state: new_pagelet_state}}
  end

  def handle_cast(
        {:refresh_subscriber_pids},
        %{connected_clients: connected_clients} = state
      ) do
    new_connected_clients = check_pids(connected_clients)

    new_state = %{
      state
      | connected_clients: new_connected_clients
    }

    update_connected(new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_info(
        {:DOWN, _monitor_ref, :process, pid, reason},
        %{connected_clients: connected_clients} = state
      ) do
    Logger.warning("Monitored PID #{inspect(pid)} died with reason: #{inspect(reason)}")

    new_connected_clients = Map.delete(connected_clients, pid)

    Logger.warning("Remaining clients: #{map_size(new_connected_clients)}")

    new_state = %{state | connected_clients: new_connected_clients}

    update_connected(new_state)
    {:noreply, new_state}
  end

  @spec monitor_pagelets(pid(), :director | :pagelet, connected_entities()) ::
          connected_entities()
  @doc """
  Given a pid and a map of connected clients {pid() -> pageletprocess()},
  starts monitoring the PID so we get notified when it dies and
  returns a new map of connected entities if said pid is not already present.

  """

  def monitor_pagelets(pid, role, connected_clients)
      when is_pid(pid) and role in [:director, :pagelet] do
    if Map.get(connected_clients, pid, :none) != :none do
      connected_clients
    else
      # start monitoring process
      Process.monitor(pid)
      pp = PageletProcess.build(pid, role)
      Map.put(connected_clients, pid, pp)
    end
  end

  def update_connected(%{
        connected_clients: connected_clients
      }) do
    clients_by_role = PageletProcess.ps_by_role(connected_clients)
    directors = Map.get(clients_by_role, :director, [])
    pagelets = Map.get(clients_by_role, :pagelet, [])

    Logger.info("UpdateConn: #{Tools.ii(directors)} cli: #{Tools.ii(pagelets)}")

    msg =
      {:now_connected, %{directors: directors, clients: pagelets}}

    for %PageletProcess{pid: d} <- directors do
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
