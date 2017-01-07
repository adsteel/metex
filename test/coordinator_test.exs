defmodule MetexCoordinatorTest do
  use ExUnit.Case
  doctest Metex.Coordinator

  @cities ["ann arbor, mi", "denver, CO", "verkhoyansk, Russia", "rio de janeiro, brazil"]

  test "#retrieve_temps" do
    results = @cities
              |> Metex.Coordinator.retrieve_temps
              |> Enum.map(fn (result) -> result.city end)
              |> Enum.sort

    assert results == ["Ann Arbor", "Denver", "Rio de Janeiro", "Verkhoyansk"]
  end
end
