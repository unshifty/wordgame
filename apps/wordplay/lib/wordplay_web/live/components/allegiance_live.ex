defmodule WordplayWeb.AllegianceLive do
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="">
      <p class="h-5 text-gray-600 text-xs uppercase">Your Allegiance</p>
      <div class="h-10 p-1 w-40 flex items-center bg-gray-200 border rounded shadow-inner">
        <%= if @team == :blue do %>
          <span class="py-1 w-1/2 bg-blue-600 text-white text-center rounded">Blue</span>
          <button phx-click="choose_team" phx-value-team="red" class="ml-1 py-1 w-1/2 text-gray-800 text-center rounded hover:bg-red-300 focus:outline-none">Red</button>
        <% else %>
          <button phx-click="choose_team" phx-value-team="blue" class="mr-1 py-1 w-1/2 text-gray-800 text-center rounded hover:bg-blue-300 focus:outline-none">Blue</button>
          <span class="py-1 w-1/2 bg-red-600 text-white text-center rounded">Red</span>
        <% end %>
      </div>
    </div>
    """
  end
end
