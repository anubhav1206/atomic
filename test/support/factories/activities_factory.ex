defmodule Atomic.Factories.ActivityFactory do
  @moduledoc """
  A factory to generate account related structs
  """

  alias Atomic.Activities.{Activity, Enrollment, Session}

  defmacro __using__(_opts) do
    quote do
      def activity_factory do
        %Activity{
          title: Faker.Beer.brand(),
          description: Faker.Lorem.paragraph()
        }
      end

      def enrollment_factory do
        %Enrollment{
          present: Enum.random([true, false]),
          session: build(:session),
          user: build(:user)
        }
      end

      def session_factory do
        %Session{
          minimum_entries: Enum.random(1..10),
          maximum_entries: Enum.random(11..20),
          start: NaiveDateTime.utc_now(),
          finish: NaiveDateTime.utc_now() |> NaiveDateTime.add(1, :hour),
          activity: build(:activity)
        }
      end
    end
  end
end
