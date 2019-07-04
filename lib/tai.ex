defmodule Tai do
  use Application

  def start(_type, _args) do
    # TODO:
    # ex_poloniex won't need to resolve env on boot when
    # the venue adapters support per account configuration
    Confex.resolve_env!(:ex_poloniex)
    Confex.resolve_env!(:tai)

    config = Tai.Config.parse()
    settings = Tai.Settings.from_config(config)

    children = [
      Tai.PubSub,
      {Tai.Events, config.event_registry_partitions},
      Tai.EventsLogger,
      {Tai.Settings, settings},
      Tai.Trading.PositionStore,
      Tai.Trading.OrderStore,
      Tai.Venues.ProductStore,
      Tai.Venues.FeeStore,
      Tai.Venues.AssetBalances,
      Tai.Venues.OrderBookFeedsSupervisor,
      Tai.Venues.StreamsSupervisor,
      {Task.Supervisor, name: Tai.TaskSupervisor, restart: :transient},
      Tai.Advisors.Supervisor
    ]

    {:ok, pid} = Supervisor.start_link(children, strategy: :one_for_one, name: Tai.Supervisor)

    config |> boot_venues!()
    config |> boot_advisor_groups!()

    {:ok, pid}
  end

  defp boot_venues!(config) do
    config
    |> Tai.Venues.Config.parse_adapters()
    |> Enum.map(fn {_, adapter} ->
      task =
        Task.Supervisor.async(
          Tai.TaskSupervisor,
          Tai.Venues.Boot,
          :run,
          [adapter],
          timeout: adapter.timeout
        )

      {task, adapter}
    end)
    |> Enum.map(fn {task, adapter} -> Task.await(task, adapter.timeout) end)
    |> Enum.each(&config.venue_boot_handler.parse_response/1)
  end

  defp boot_advisor_groups!(config) do
    config
    |> Tai.Advisors.specs(start_on_boot: true)
    |> Tai.Advisors.start()
  end
end
