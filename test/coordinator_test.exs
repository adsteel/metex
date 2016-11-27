defmodule MetexCoordinatorTest do
  use ExUnit.Case
  doctest Metex.Coordinator

  test "#retrieve_temps" do
    cities = ["ann arbor, mi", "denver, CO", "verkhoyansk, Russia"]
    temps = Metex.Coordinator.retrieve_temps(cities)
    keys = Map.keys(temps) |> Enum.sort

    assert keys == ["Ann Arbor", "Denver", "Verkhoyansk"]
  end
end
