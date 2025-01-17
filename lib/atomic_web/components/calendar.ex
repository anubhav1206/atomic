defmodule AtomicWeb.Components.Calendar do
  @moduledoc false
  use AtomicWeb, :component

  alias Timex.Duration

  import AtomicWeb.CalendarUtils
  import AtomicWeb.Components.CalendarMonth
  import AtomicWeb.Components.CalendarWeek

  def calendar(
        %{
          current_path: current_path,
          params: params,
          mode: mode,
          time_zone: time_zone
        } = assigns
      ) do
    assigns =
      assigns
      |> assign_date(current_path, params, time_zone)

    assigns =
      case mode do
        "week" ->
          assigns
          |> assigns_week(current_path, time_zone, params)

        "month" ->
          assigns
          |> assigns_month(current_path, time_zone, params)

        _ ->
          assigns
          |> assigns_month(current_path, time_zone, params)
      end

    ~H"""
    <div x-data="{ mode_view: false }" class="flex-col lg:flex lg:h-full">
      <header class="my-4 flex flex-col sm:flex-row">
        <div class="flex-1">
          <div class="relative z-20 flex w-full items-end justify-between lg:flex-none">
            <span class="font-base pl-2 text-base text-zinc-900">
              <%= if @mode == "month" do %>
                <time datetime={@beginning_of_month}><%= Timex.format!(@beginning_of_month, "{Mshort} {YYYY}") %></time>
              <% else %>
                <%= case date_to_month(@beginning_of_week) == date_to_month(@end_of_week) do %>
                  <% true -> %>
                    <time datetime={@beginning_of_week}><%= Timex.format!(@beginning_of_week, "{Mshort} {YYYY}") %></time>
                  <% _ -> %>
                    <%= if date_to_year(@beginning_of_week) == date_to_year(@end_of_week) do %>
                      <time datetime={@beginning_of_week}><%= Timex.format!(@beginning_of_week, "{Mshort}") %> - <%= Timex.format!(@end_of_week, "{Mshort} {YYYY}") %></time>
                    <% else %>
                      <time datetime={@beginning_of_week}><%= Timex.format!(@beginning_of_week, "{Mshort} {YYYY}") %> - <%= Timex.format!(@end_of_week, "{Mshort} {YYYY}") %></time>
                    <% end %>
                <% end %>
              <% end %>
            </span>
            <div class="flex items-center">
              <div class="flex items-center md:items-stretch">
                <%= live_patch to: "#{if @mode == "month" do @previous_month_path else @previous_week_path end}" do %>
                  <button type="button" class="flex items-center justify-center py-2 pr-4 pl-3 text-zinc-400 hover:text-zinc-500 focus:relative md:w-9 md:px-2 hover:bg-zinc-50">
                    <span class="sr-only">Previous month</span>
                    <Heroicons.Solid.chevron_left class="h-3 w-3 sm:h-5 sm:w-5" />
                  </button>
                <% end %>
                <%= live_patch to: "#{if @mode == "month" do @present_month_path else @present_week_path end}" do %>
                  <button type="button" class="hidden px-3.5 h-full text-sm font-medium text-zinc-700 md:block hover:text-zinc-900 focus:relative hover:bg-zinc-50">
                    <%= gettext("Today") %>
                  </button>
                <% end %>
                <%= live_patch to: "#{if @mode == "month" do @next_month_path else @next_week_path end}" do %>
                  <button type="button" class="flex items-center justify-center py-2 pr-3 pl-4 text-zinc-400 hover:text-zinc-500 focus:relative md:w-9 md:px-2 hover:bg-zinc-50">
                    <span class="sr-only">Next month</span>
                    <Heroicons.Solid.chevron_right class="h-3 w-3 sm:h-5 sm:w-5" />
                  </button>
                <% end %>
              </div>
              <div class="hidden md:ml-4 md:flex md:items-center">
                <div class="relative">
                  <a @click="mode_view = !mode_view" class="cursor-pointer flex items-center py-2 pr-2 pl-3 text-sm font-medium text-zinc-700 hover:bg-zinc-50" id="menu-button" aria-expanded="false" aria-haspopup="true">
                    <%= if @mode == "month" do
                      gettext("Month view")
                    else
                      gettext("Week view")
                    end %>
                    <Heroicons.Solid.chevron_down class="ml-2 h-5 w-5 text-zinc-400" />
                  </a>

                  <div :class="mode_view ?'block' : 'hidden'" class="absolute right-0 mt-3 w-36 origin-top-right overflow-hidden rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none" role="menu" aria-orientation="vertical" aria-labelledby="menu-button" tabindex="-1">
                    <div class="py-1" role="none">
                      <%= live_patch to: @current_week_path do %>
                        <button
                          type="button"
                          @click="mode_view = false"
                          class={
                            "block px-4 w-full py-2 text-sm #{if @mode == "week" do
                              "hidden"
                            else
                              "block"
                            end}"
                          }
                          role="menuitem"
                          tabindex="-1"
                          id="menu-0-item-2"
                        >
                          <%= gettext("Week view") %>
                        </button>
                      <% end %>
                      <%= live_patch to: @current_month_path do %>
                        <button
                          type="button"
                          @click="mode_view = false"
                          class={
                            "block px-4 w-full py-2 text-sm #{if @mode == "month" do
                              "hidden"
                            else
                              "block"
                            end}"
                          }
                          role="menuitem"
                          tabindex="-1"
                          id="menu-0-item-3"
                        >
                          <%= gettext("Month view") %>
                        </button>
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
              <div class="relative ml-6 md:hidden">
                <button type="button" @click="mode_view = !mode_view" class="-mx-2 flex items-center rounded-full border border-transparent p-2 text-zinc-400 hover:text-zinc-500" id="menu-0-button" aria-expanded="false" aria-haspopup="true">
                  <span class="sr-only">Open menu</span>
                  <Heroicons.Solid.dots_horizontal class="h-3 w-3 sm:h-5 sm:w-5" />
                </button>

                <div :class="mode_view ?'block' : 'hidden'" class="absolute right-0 mt-3 w-36 origin-top-right divide-y divide-zinc-100 overflow-hidden rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                  <div class="py-1" role="none">
                    <%= live_patch to: "#{if @mode == "month" do @present_month_path else @present_week_path end}" do %>
                      <button type="button" @click="mode_view = false" class="block w-full px-4 py-2 text-sm text-zinc-700" role="menuitem" tabindex="-1" id="menu-1-item-1">
                        <%= gettext("Today") %>
                      </button>
                    <% end %>
                    <div class="mx-4 border-b border-zinc-200 " />
                    <%= live_patch to: @present_week_path do %>
                      <button
                        type="button"
                        @click="mode_view = false"
                        class={
                          "block px-4 w-full py-2 text-sm #{if @mode == "week" do
                            "hidden"
                          else
                            "block"
                          end}"
                        }
                        role="menuitem"
                        tabindex="-1"
                        id="menu-1-item-2"
                      >
                        <%= gettext("Week view") %>
                      </button>
                    <% end %>
                    <%= live_patch to: @present_month_path do %>
                      <button
                        type="button"
                        @click="mode_view = false"
                        class={
                          "block px-4 w-full py-2 text-sm #{if @mode == "month" do
                            "hidden"
                          else
                            "block"
                          end}"
                        }
                        role="menuitem"
                        tabindex="-1"
                        id="menu-1-item-3"
                      >
                        <%= gettext("Month view") %>
                      </button>
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </header>
      <%= if @mode == "month" do %>
        <.calendar_month id="calendar_month" current_organization={@current_organization} current_path={@current_path} params={@params} sessions={@sessions} beginning_of_month={@beginning_of_month} end_of_month={@end_of_month} time_zone={@time_zone} />
      <% else %>
        <.calendar_week id="calendar_week" current_organization={@current_organization} current_path={@current_path} current={@current} params={@params} sessions={@sessions} beginning_of_week={@beginning_of_week} end_of_week={@end_of_week} time_zone={@time_zone} />
      <% end %>
    </div>
    """
  end

  defp assign_date(assigns, current_path, params, time_zone) do
    current = current_from_params(time_zone, params)

    current_year =
      current
      |> date_to_year()

    current_month =
      current
      |> date_to_month()

    current_day =
      current
      |> date_to_day()

    present_year =
      Timex.today(time_zone)
      |> date_to_year()

    present_month =
      Timex.today(time_zone)
      |> date_to_month()

    present_day =
      Timex.today(time_zone)
      |> date_to_day()

    present_week_path =
      build_path(current_path, %{
        mode: "week",
        day: present_day,
        month: present_month,
        year: present_year
      })

    current_week_path =
      build_path(current_path, %{
        mode: "week",
        day: current_day,
        month: current_month,
        year: current_year
      })

    present_month_path =
      build_path(current_path, %{
        mode: "month",
        day: present_day,
        month: present_month,
        year: present_year
      })

    current_month_path =
      build_path(current_path, %{
        mode: "month",
        day: current_day,
        month: current_month,
        year: current_year
      })

    assigns
    |> assign(present_month_path: present_month_path)
    |> assign(present_week_path: present_week_path)
    |> assign(current_month_path: current_month_path)
    |> assign(current_week_path: current_week_path)
    |> assign(current: current)
  end

  defp assigns_week(assigns, current_path, time_zone, params) do
    current = current_from_params(time_zone, params)
    beginning_of_week = Timex.beginning_of_week(current)
    end_of_week = Timex.end_of_week(current)

    previous_week_date =
      current
      |> Timex.add(Duration.from_days(-7))

    next_week_date =
      current
      |> Timex.add(Duration.from_days(7))

    previous_week_day =
      previous_week_date
      |> date_to_day()

    previous_week_month =
      previous_week_date
      |> date_to_month()

    previous_week_year =
      previous_week_date
      |> date_to_year()

    next_week_day =
      next_week_date
      |> date_to_day()

    next_week_month =
      next_week_date
      |> date_to_month()

    next_week_year =
      next_week_date
      |> date_to_year()

    previous_week_path =
      build_path(current_path, %{
        mode: "week",
        day: previous_week_day,
        month: previous_week_month,
        year: previous_week_year
      })

    next_week_path =
      build_path(current_path, %{
        mode: "week",
        day: next_week_day,
        month: next_week_month,
        year: next_week_year
      })

    assigns
    |> assign(beginning_of_week: beginning_of_week)
    |> assign(end_of_week: end_of_week)
    |> assign(previous_week_path: previous_week_path)
    |> assign(next_week_path: next_week_path)
  end

  defp assigns_month(assigns, current_path, time_zone, params) do
    current = current_from_params(time_zone, params)
    beginning_of_month = Timex.beginning_of_month(current)
    end_of_month = Timex.end_of_month(current)

    last_day_previous_month =
      beginning_of_month
      |> Timex.add(Duration.from_days(-1))

    first_day_next_month =
      end_of_month
      |> Timex.add(Duration.from_days(1))

    previous_month =
      last_day_previous_month
      |> date_to_month()

    next_month =
      first_day_next_month
      |> date_to_month()

    previous_month_year =
      last_day_previous_month
      |> date_to_year()

    next_month_year =
      first_day_next_month
      |> date_to_year()

    previous_month_path =
      build_path(current_path, %{mode: "month", month: previous_month, year: previous_month_year})

    next_month_path =
      build_path(current_path, %{mode: "month", month: next_month, year: next_month_year})

    assigns
    |> assign(beginning_of_month: beginning_of_month)
    |> assign(end_of_month: end_of_month)
    |> assign(previous_month_path: previous_month_path)
    |> assign(next_month_path: next_month_path)
  end
end
