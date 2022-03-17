defmodule WordspyWeb.Presence do
  use Phoenix.Presence,
    otp_app: :wordspy,
    pubsub_server: Wordspy.PubSub

  alias WordspyWeb.Presence

  def meta_value(%{metas: metas}, key) do
    meta_value(metas, key)
  end
  def meta_value(metas, key) when is_list(metas) do
    List.first(metas)[key]
  end

  def count(topic, key, value) when is_binary(topic) do
    topic
    |> Presence.list()
    |> Presence.count(key, value)
  end

  def count(presence_data, key, value) do
    presence_data
    |> Enum.filter(fn {_id, metadata} -> meta_value(metadata, key) == value end)
    |> Enum.count()
  end
end
