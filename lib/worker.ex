defmodule Metex.Worker do
  use GenServer

  @apikey System.get_env("OPENWEATHERMAP_APIKEY")

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def fetch(coordinator_pid, location) do
    {:ok, worker_pid} = start_link
    GenServer.cast(worker_pid, {:fetch, :coordinator_pid, coordinator_pid, :location, location})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:fetch, :coordinator_pid, coordinator_pid, :location, location}, state) do
    case temperature_of(location) do
      {:ok, temp, city} ->
        Metex.Coordinator.put(coordinator_pid, city, temp)
        {:noreply, state}
      _ ->
        {:noreply, state}
    end
  end

  ## Helper Functions

  defp temperature_of(location) do
    url_for(location) |> HTTPoison.get |> parse_response
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{@apikey}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode! |> compute_temperature
  end
  defp parse_response(_), do: :error

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      city = json["name"]
      {:ok, temp, city}
    rescue
      _ -> :error
    end
  end
end
