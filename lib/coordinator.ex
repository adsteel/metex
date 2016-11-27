defmodule Metex.Coordinator do
  use GenServer

  ## Client API

  defp start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def retrieve_temps(locations) do
    {:ok, coordinator_pid} = start_link

    locations |> Enum.each(fn location ->
      Metex.Worker.fetch(coordinator_pid, location)
    end)

    confirm_all(coordinator_pid, locations, 0)
  end

  defp confirm_all(coordinator_pid, locations, count) do
    :timer.sleep(100)

    expected_count = Enum.count(locations)
    {:ok, :str, _str, state: state} = get_all(coordinator_pid)
    actual_count = Enum.count(state)

    cond do
      expected_count == actual_count ->
        state
      count > 20 ->
        :timeout_error
      true ->
        confirm_all(coordinator_pid, locations, count + 1)
    end
  end

  def put(coordinator_pid, location, temp) do
    GenServer.cast(coordinator_pid, {:put, :location, location, :temp, temp})
  end

  def get_all(coordinator_pid) do
    GenServer.call(coordinator_pid, :get_all)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:put, :location, location, :temp, temp}, state) do
    state = Map.put(state, location, temp)
    {:noreply, state}
  end

  def handle_call(:get_all, _from, state) do
    str = state |> Enum.map(fn {k, v} -> "#{k}: #{v}" end) |> Enum.join(", ")
    {:reply, {:ok, :str, str, state: state}, state}
  end
end
