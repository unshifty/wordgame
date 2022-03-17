defmodule WordspyWeb.TeamPanelLive do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, socket}
  end

  def render(%{assigns: assigns, team: team}) do
    ~L"""
    <div class="flex flex-col w-40 text-gray-800 sm:w-56">
      <div class="mt-5 p-2 flex-1 flex flex-col justify-between bg-gray-300 rounded <%= container_class(@game, team) %>">
        <div class="flex items-center">
          <p class="px-1 uppercase <%= bg_class(team) %> text-white rounded"><%= team_name(team) %><span class="ml-2">🧑<%= @user_count[team] %></span></p>
          <p class="ml-auto text-right">🔍<%= revealed_tiles(@game, team) %>/<%= total_tiles(@game, team) %></p>
        </div>
        <div class="mt-2">
          <%= if @game.turn == team and @team == team do %>
          <button phx-click="end_turn"
                  class="py-2 w-full btn-basic btn-tertiary <%= text_class(team) %>">
            End Turn
          </button>
          <% else %>
          <p class="w-full px-2 py-2 font-semibold text-center text-gray-500 rounded"><%= team_name(@game.turn) %>'s Turn</p>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def bg_class(team) do
    %{red: "bg-red-600", blue: "bg-blue-600"}[team]
  end

  def text_class(team) do
    %{red: "text-red-600", blue: "text-blue-600"}[team]
  end

  def shadow_class(team) do
    %{red: "shadow-red", blue: "shadow-blue"}[team]
  end

  def container_class(%{turn: :red}, :red),   do: "border border-red-600 shadow-lg"
  def container_class(%{turn: :blue}, :blue), do: "border border-blue-600 shadow-lg"
  def container_class(_, _),                  do: "border border-gray-400"

  def border_class(team) do
    %{red: "border border-red-600", blue: "border border-blue-600"}[team]
  end

  def revealed_tiles(game, team) do
    Wordspy.Game.revealed_tiles(game, team)
  end

  def total_tiles(game, team) do
    Wordspy.Game.total_tiles(game, team)
  end

  def team_name(:red), do: "Red"
  def team_name(:blue), do: "Blue"
end
