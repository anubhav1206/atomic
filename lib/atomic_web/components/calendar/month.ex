defmodule AtomicWeb.Components.CalendarMonth do
  @moduledoc false
  use AtomicWeb, :component

  import AtomicWeb.CalendarUtils
  import AtomicWeb.Components.Badges

  def calendar_month(assigns) do
    organization = assigns.current_organization

    ~H"""
    <div class="rounded-lg shadow ring-1 ring-black ring-opacity-5 lg:flex lg:flex-auto lg:flex-col">
      <div class="grid grid-cols-7 gap-px rounded-t-lg border-b border-zinc-300 bg-zinc-200 text-center text-xs font-semibold leading-6 text-zinc-700 lg:flex-none">
        <div class="rounded-tl-lg bg-white py-2">
          M<span class="sr-only sm:not-sr-only">on</span>
        </div>
        <div class="bg-white py-2">
          T<span class="sr-only sm:not-sr-only">ue</span>
        </div>
        <div class="bg-white py-2">
          W<span class="sr-only sm:not-sr-only">ed</span>
        </div>
        <div class="bg-white py-2">
          T<span class="sr-only sm:not-sr-only">hu</span>
        </div>
        <div class="bg-white py-2">
          F<span class="sr-only sm:not-sr-only">ri</span>
        </div>
        <div class="bg-white py-2">
          S<span class="sr-only sm:not-sr-only">at</span>
        </div>
        <div class="rounded-tr-lg bg-white py-2">
          S<span class="sr-only sm:not-sr-only">un</span>
        </div>
      </div>
      <div class="flex bg-zinc-200 text-xs leading-6 text-zinc-700 lg:flex-auto">
        <div class="grid w-full grid-cols-7 gap-px overflow-hidden rounded-b-lg">
          <%= for i <- 0..@end_of_month.day - 1 do %>
            <.day index={i} current_organization={@current_organization} params={@params} current_path={@current_path} sessions={@sessions} date={Timex.shift(@beginning_of_month, days: i)} time_zone={@time_zone} />
          <% end %>
        </div>
      </div>
    </div>
    <div class="py-4 lg:hidden">
      <ol class="divide-y divide-zinc-200 overflow-hidden rounded-lg bg-white text-sm shadow ring-1 ring-black ring-opacity-5">
        <%= for session <- get_date_sessions(@sessions, current_from_params(@time_zone, @params)) do %>
          <%= if session.activity do %>
            <%= live_patch to: Routes.activity_show_path(AtomicWeb.Endpoint, :show, session.activity, organization) do %>
              <li class="group flex p-4 pr-6 focus-within:bg-zinc-50 hover:bg-zinc-50">
                <div class="flex-auto">
                  <p class="font-semibold text-zinc-900">
                    <%= session.activity.title %>
                    <%!-- <%= if Gettext.get_locale() == "en" do
                      if session.activity.title_en do
                        session.activity.title_en
                      else
                        ""
                      end
                    else
                      if session.activity.title_pt do
                        session.activity.title_pt
                      else
                        ""
                      end
                    end %> --%>
                  </p>
                  <div class="flex flex-row items-center gap-x-2 pt-2">
                    <.badge_dot url={Routes.activity_index_path(AtomicWeb.Endpoint, :index, organization)} color="purple">
                      Activity
                    </.badge_dot>
                    <time datetime={session.start} class="flex items-center text-zinc-700">
                      <Heroicons.Solid.clock class="mr-2 h-5 w-5 text-zinc-400" />
                      <%= Calendar.strftime(session.start, "%Hh%M") %>
                    </time>
                  </div>
                </div>
              </li>
            <% end %>
          <% end %>
        <% end %>
      </ol>
    </div>
    """
  end

  defp day(
         %{index: index, date: date, time_zone: time_zone, current_organization: organization} =
           assigns
       ) do
    weekday = Timex.weekday(date, :monday)
    today? = Timex.compare(date, Timex.today(time_zone))

    class =
      class_list([
        {"relative py-2 px-3 lg:min-h-[110px] lg:flex hidden", true},
        {col_start(weekday), index == 0},
        {"bg-white", today? >= 0},
        {"bg-zinc-50 text-zinc-500", today? < 0}
      ])

    assigns =
      assigns
      |> assign(disabled: today? < 0)
      |> assign(:text, Timex.format!(date, "{D}"))
      |> assign(:class, class)
      |> assign(:date, date)
      |> assign(:today?, today?)

    ~H"""
    <div class={@class}>
      <time
        date-time={@date}
        class={
          "ml-auto lg:ml-0 pr-2 lg:pr-0 #{if today? == 0 do
            "flex h-6 w-6 items-center justify-center rounded-full bg-indigo-400 font-semibold text-white shrink-0"
          end}"
        }
      >
        <%= @text %>
      </time>
      <ol class="mt-3 w-full">
        <%= for session <- get_date_sessions(@sessions, @date) do %>
          <li>
            <%= if session.activity do %>
              <%= live_patch to: Routes.activity_show_path(AtomicWeb.Endpoint, :show, organization, session.id), class: "group flex" do %>
                <p class="text-zinc-600 group-hover:text-zinc-800 flex-auto truncate font-medium">
                  <%= session.activity.title %>
                  <%!-- <%= if Gettext.get_locale() == "en" do
                    if session.activity.title_en do
                      session.activity.title_en
                    else
                      ""
                    end
                  else
                    if session.activity.title_pt do
                      session.activity.title_pt
                    else
                      ""
                    end
                  end %> --%>
                </p>
                <time datetime={session.start} class="text-zinc-600 group-hover:text-zinc-800 mx-2 hidden flex-none xl:block"><%= Calendar.strftime(session.start, "%Hh") %></time>
              <% end %>
            <% end %>
          </li>
        <% end %>
      </ol>
    </div>
    <%= live_patch to: build_path(@current_path, %{mode: "month", day: date_to_day(@date), month: date_to_month(@date), year: date_to_year(@date)}), class: "#{if @index == 0 do col_start(weekday) end} min-h-[56px] flex w-full flex-col bg-white px-3 py-2 text-zinc-900 hover:bg-zinc-100 focus:z-10 lg:hidden" do %>
      <time
        date-time={@date}
        class={
          "ml-auto lg:ml-0 #{if current_from_params(@time_zone, @params) == @date do
            "ml-auto flex h-6 w-6 items-center justify-center rounded-full #{if today? == 0 do
              "bg-indigo-700"
            else
              "bg-zinc-900"
            end} text-white shirk-0"
          else
            if today? == 0 do
              "text-indigo-700"
            end
          end}"
        }
      >
        <%= @text %>
      </time>
      <%= if (sessions = get_date_sessions(@sessions, @date)) != [] do %>
        <span class="sr-only">Enum.count(sessions) events</span>
        <span class="flex flex-wrap-reverse -mx-0.5 mt-auto">
          <%= for session <- sessions do %>
            <%= if session.activity do %>
              <span class="mx-0.5 mb-1 h-1.5 w-1.5 rounded-full bg-zinc-700"></span>
            <% end %>
          <% end %>
        </span>
      <% end %>
    <% end %>
    """
  end
end
