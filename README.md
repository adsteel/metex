# Metex

A simple, concurrent [openweathermap](openweathermap.org) API wrapper written in Elixir.


Usage:

1. Create an openweather account at http://openweathermap.org.
2. Set your `OPENWEATHERMAP_APIKEY` env var to your new openweather API key.
3. Run Metex.

```elixir
$ iex -S mix
> cities = ["ann arbor, mi", "denver, CO", "verkhoyansk, Russia"]
> Metex.Coordinator.retrieve_temps(cities)
%{"Ann Arbor" => 3.9, "Denver" => 5.1, "Verkhoyansk" => -44.4}
```
