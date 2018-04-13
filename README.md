# Tai
[![Build Status](https://circleci.com/gh/fremantle-capital/tai.png)](https://circleci.com/gh/fremantle-capital/tai)

A trading toolkit built with [Elixir](https://elixir-lang.org/) that runs on the [Erlang virtual machine](http://erlang.org/faq/implementations.html)

## WARNING

`tai` is alpha quality software. It passes our test suite but the API is highly 
likely to change and no effort will be made to maintain backwards compatibility at this time.
We are working to make `tai` production quality software.

[Tai on GitHub](https://github.com/fremantle-capital/tai) | [Install](#install) | [Usage](#usage) | [Debugging](#debugging) | [Configuration](#configuration) | [Examples](./examples)


## Supported Exchanges

| Exchange       | Live Order Book  | Orders |
|----------------|:----:|:--------------:|
| GDAX           | [x] | [x] |
| Binance        | [x] | [ ] |
| Poloniex       | [x] | [ ] |

## Planned Exchanges

| Exchange       | Live Order Book  | Orders |
|----------------|:----:|:--------------:|
| Bitfinex           | [ ] | [ ] |
| Bitflyer           | [ ] | [ ] |
| Bithumb            | [ ] | [ ] |
| Bitmex             | [ ] | [ ] |
| Bitstamp           | [ ] | [ ] |
| Bittrex            | [ ] | [ ] |
| Gemini             | [ ] | [ ] |
| HitBtc             | [ ] | [ ] |
| Huobi              | [ ] | [ ] |
| Kraken             | [ ] | [ ] |
| OkCoin             | [ ] | [ ] |
| ...                | [ ] | [ ] |

[Full List...](./PLANNED_EXCHANGES.md)

## Install

Tai requires Elixir 1.6. Add `tai` to your list of dependencies in `mix.exs`

```elixir
def deps do
  [
    {:tai, "~> 0.0.1"}
  ]
end
```

Or use the lastest from `master`

```elixir
def deps do
  [
    {:tai, github: "fremantle-capital/tai"}
  ]
end
```

## Usage

`tai` currently runs as an interactive mix console application.

Once started it subscribes to the configured order book feeds and starts 
[advisors](#advisors) to process the changes in the order book where you can 
execute orders using a uniform API across exchanges.

```bash
iex -S mix
```

### Commands

You can inspect the state of your orders and feeds or execute manual orders using the following commands

#### help

Display the available commands and usage examples

```bash
iex(1)> help
* balance
* markets
* orders
* buy_limit exchange(:gdax), symbol(:btcusd), price(101.12), size(1.2)
* sell_limit exchange(:gdax), symbol(:btcusd), price(101.12), size(1.2)
* order_status exchange(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
* cancel_order exchange(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
```

#### balance

Return the USD value across all configured exchanges


```
iex(2)> balance
$100.13
```

#### markets

Displays the live top of the order book for the configured feeds. It includes 
the time they were processed locally and if supported, the time they were sent 
from the exchange. This allows you to monitor if a feed is under backpressure and
starting to fall behind as it updates it's order books.

```
iex(3)> markets
+---------+---------+-----------+-----------+------------+--------------+------------------+-----------------------+------------------+-----------------------+
|    Feed |  Symbol | Bid Price | Ask Price |   Bid Size |     Ask Size | Bid Processed At | Bid Server Changed At | Ask Processed At | Ask Server Changed At |
+---------+---------+-----------+-----------+------------+--------------+------------------+-----------------------+------------------+-----------------------+
| binance | btcusdt |    8430.0 |   8439.91 |   0.349355 |     1.021896 |     1 second ago |          1 second ago |              now |                   now |
| binance | ltcusdt |    159.53 |    159.58 |   10.54534 |      1.02855 |    9 seconds ago |         9 seconds ago |    4 seconds ago |         4 seconds ago |
| binance | ethusdt |    519.67 |     520.0 |    0.08984 |      2.33198 |    7 seconds ago |         7 seconds ago |              now |                   now |
|    gdax |  btcusd |   8430.86 |   8430.87 | 0.01448655 |  24.32791169 |    3 seconds ago |         3 seconds ago |     1 second ago |          1 second ago |
|    gdax |  ltcusd |    159.97 |    159.98 |    0.00002 | 478.22565196 |   28 seconds ago |        28 seconds ago |              now |                   now |
|    gdax |  ethusd |    520.93 |    520.94 | 9.48431449 |  79.37008001 |              now |                   now |     1 second ago |         2 seconds ago |
+---------+---------+-----------+-----------+------------+--------------+------------------+-----------------------+------------------+-----------------------+
```

#### orders

Displays the list of orders and their status.

**[IN PROGRESS:](https://github.com/fremantle-capital/tai/tree/order-feed-spike)**

As the lifecycle of the order changes i.e. partial fills, process events and 
update in the background so that the information is available when you re-run 
the `orders` command.

```
iex(4)> orders
+----------+--------+-----------+-------+------+--------+--------------------------------------+-----------+----------------+------------+
| Exchange | Symbol |      Type | Price | Size | Status |                            Client ID | Server ID |    Enqueued At | Created At |
+----------+--------+-----------+-------+------+--------+--------------------------------------+-----------+----------------+------------+
|     gdax | btcusd | buy_limit | 100.1 |  0.1 |  error | a6aa15bc-b271-486f-ab40-f9b35b2cd223 |           | 20 minutes ago |            |
+----------+--------+-----------+-------+------+--------+--------------------------------------+-----------+----------------+------------+
```

## Advisors

Run in their own process and receive asynchronous events when the order books change.
They are intended to be run without supervison to analyze data or execute trading strategies.

[Examples](examples/advisors)

## Debugging

Error, warning and information messages are written to a separate log file for 
each environment in the `logs` directory.

To monitor a stream of logs you can use the `tail` command

```bash
tail -f logs/dev.log
```

If you would like to filter the log messages to target certain patterns or 
processes you can combine it with the `grep` command.

```bash
tail -f logs/dev.log | grep advisor_create_and_cancel_pending_order
```

## Configuration

Each environment can have their own configuration. Take a look at the [example 
dev configuration](config/dev.exs.example) for available options.

## Authors

* Alex Kwiatkowski - alex+git@rival-studios.com

## License

`tai` is released under the [MIT license](./LICENSE.md)
