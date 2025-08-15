defmodule Coolors.PageletProcessTest do
  # test/coolors/pagelet_process_test.exs
  use ExUnit.Case, async: true
  doctest Coolors.PageletProcess

  alias Coolors.PageletProcess

  def newPid(), do: spawn(fn -> :ok end)

  describe "create" do
    test "empty" do
      p0 = newPid()
      assert %PageletProcess{pid: ^p0, role: :director} = PageletProcess.build(p0, :director)
    end
  end

  describe "split by role" do
    test "split" do
      p0 = newPid()
      p1 = newPid()
      p2 = newPid()

      mV = %{
        p0 => PageletProcess.build(p0, :director),
        p1 => PageletProcess.build(p1, :pagelet),
        p2 => PageletProcess.build(p2, :pagelet)
      }

      assert %{director: [%{pid: ^p0}], pagelet: [_, _]} = PageletProcess.ps_by_role(mV)
    end
  end
end
