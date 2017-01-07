defmodule Metex.Coordinator do
  def retrieve_temps(locations) do
    locations
    |> Enum.map(&Metex.Worker.fetch/1)
    |> Task.yield_many
    |> collect
    |> Enum.reject(&is_nil/1)
  end

  defp collect(results) do
    Enum.map(results, fn {_task, result} ->
      case result do
        { :ok, { :ok, temp, city } } -> %{ temp: temp, city: city }
        _ -> nil
      end
    end)
  end
end
