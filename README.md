# Distributed Counters

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start node with `PORT=4000 iex --sname nodename -S mix phx.server`


# Description

It's a distributed database with a kind of consistency requirements but a flat structure. I've decided to separate the system into the next elements:

 - operations create (maybe not the best name) and show
business-logic or input requests from web

 - bus
transport between nodes based on phoenix.pubsub
Has interface to broadcast new metrics, and receive broadcasted messages. Also, the bus stores several messages and send it to storage (described down below) by chunks for portioned concurrent writing (poor imitation of pool)

- storage
service that saves counters into ets

also, I've used libcluster for easy dynamic clustering

The most challenging moment for me was a "All counters should be distributed to available nodes connected through Distributed Erlang".
I understand this like "Information about every counter should be placed on every node ASAP", maybe I am wrong, but anyway it was a main driver of architecture.
At the same time, it's a database for metrics, and it requires very fast insert operations, and we can disregard read operation speed. And because I didn't want to solve all problems of CAP theorem as part of the test task, I decided to make a "system" that fit the requirements of the task, which should work fast enough but hasn't any sync solutions for sane consistency.