defmodule Coolors.PageletProcess do
  @moduledoc """
  This struct is used to track the state of connected clients
  in `PageletSrv`,  both directors and pagelets.

  """
  alias Coolors.PageletProcess
  alias Coolors.Tools
  use TypedStruct

  typedstruct do
    @typedoc "A connected client"

    field :user, String.t(), enforce: true
    field :role, :director | :pagelet, enforce: true
    field :pid, pid(), enforce: true
    field :ip, String.t()
    field :started_at, any()
  end

  def build(pid, role),
    do: %PageletProcess{pid: pid, role: role, user: inspect(pid), started_at: Tools.now()}

  @doc """
  Given a map {any -> PageletProcess}, returns a map of {role -> [PageletProcess]}
  """
  def ps_by_role(m_processes) when is_map(m_processes) do
    m_processes
    |> Map.values()
    |> Enum.group_by(fn %PageletProcess{role: r} -> r end)
  end
end
