defmodule Coolors.Rooms do
  @moduledoc """
  Contains one PageletSrv for each open room.


  """

  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: {:global, __MODULE__})
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # Helper functions to interact with the globally registered supervisor

  @doc """


      {:ok, room_pid} = Coolors.Rooms.start_child({RoomServer, "lobby"})

  """

  def start_child(child_spec) do
    DynamicSupervisor.start_child({:global, __MODULE__}, child_spec)
  end

  def terminate_child(pid) do
    DynamicSupervisor.terminate_child({:global, __MODULE__}, pid)
  end

  def which_children do
    DynamicSupervisor.which_children({:global, __MODULE__})
  end

  def count_children do
    DynamicSupervisor.count_children({:global, __MODULE__})
  end

  def pid_for_pagelet(pagelet_id) do
    pid = :global.whereis_name(pagelet_id)

    case pid do
      :undefined ->
        case start_child({Coolors.PageletSrv, pagelet_id}) do
          {:ok, pid} -> pid
          e -> {:error, e}
        end

      _ ->
        pid
    end
  end
end
