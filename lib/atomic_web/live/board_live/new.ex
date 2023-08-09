defmodule AtomicWeb.BoardLive.New do
  @moduledoc false
  use AtomicWeb, :live_view

  alias Atomic.Accounts
  alias Atomic.Organizations.UserOrganization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"organization_id" => _organization_id}, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, gettext("New Board"))
     |> assign(:user_organization, %UserOrganization{})
     |> assign(:users, Enum.map(Accounts.list_users(), fn u -> [key: u.email, value: u.id] end))
     |> assign(:current_user, socket.assigns.current_user)}
  end
end
