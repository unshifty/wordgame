defmodule WordplayWeb.TeamPanelLive do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, socket}
  end

  def render(%{assigns: assigns, team: team}) do
    ~L"""
    <div class="w-40 sm:w-56 flex flex-col">
      <%= if @game.turn == team do %>
      <div class="bg-gray-300 <%= border_class(team) %> rounded shadow-lg">
      <% else %>
      <div class="bg-gray-300 border border-gray-400 rounded">
      <% end %>
        <div class="p-2 flex flex-col text-gray-800">
          <div class="flex items-center">
            <p class="px-1 uppercase <%= bg_class(team) %> text-white rounded"><%= team_name(team) %><span class="ml-2">🧑<%= @user_count[team] %></span></p>
            <p class="ml-auto text-right">🔍<%= revealed_tiles(@game, team) %>/<%= total_tiles(@game, team) %></p>
          </div>
          <div class="mt-2">
            <%= if @game.turn == team and @team == team do %>
              <button phx-click="end_turn"
                      class="px-2 py-1 w-full <%= text_class(team) %> bg-white font-semibold rounded shadow hover:bg-gray-100 focus:outline-none">
                End Turn
              </button>
            <% else %>
              <p class="w-full px-2 py-1 text-center text-gray-500 font-semibold rounded"><%= team_name(@game.turn) %>'s Turn</p>
            <% end %>
          </div>
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
