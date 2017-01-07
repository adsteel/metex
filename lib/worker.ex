defmodule Metex.Worker do
  @apikey System.get_env("OPENWEATHERMAP_APIKEY")

  def fetch(location) do
    Task.async(fn -> temperature_of(location) end)
  end

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
