defmodule Atomic.Repo.Seeds.Activities do
  alias Atomic.Accounts.User
  alias Atomic.Activities
  alias Atomic.Activities.{Activity, Enrollment, Session, SessionDepartment}
  alias Atomic.Organizations.Department
  alias Atomic.Repo

  def run do
    seed_activities()
    seed_enrollments()
    seed_session_departments()
  end

  def seed_activities do
    case Repo.all(Activity) do
      [] ->
        location = %{
          name: "Departamento de Informática da Universidade do Minho",
          url: "https://web.di.uminho.pt"
        }

        %Activity{
          title: "Test Activity",
          description: "This is a test activity",
          sessions: [
            %{
              # We make these dates relative to current date so we are able to quickly test
              start:
                NaiveDateTime.add(NaiveDateTime.utc_now(), -12, :hour)
                |> NaiveDateTime.truncate(:second),
              # the certificate delivery job
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), -8, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location,
              minimum_entries: 0,
              maximum_entries: 10,
              enrolled: 0
            }
          ]
        }
        |> Repo.insert!()

        %Activity{
          title: "Test Activity 2",
          description: "This is a test activity",
          sessions: [
            %{
              minimum_entries: 0,
              maximum_entries: 10,
              enrolled: 0,
              start: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 2, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location
            }
          ]
        }
        |> Repo.insert!()

        %Activity{
          title: "Test Activity 3",
          description: "This is a test activity",
          sessions: [
            %{
              minimum_entries: 0,
              maximum_entries: 10,
              enrolled: 0,
              start:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 1, :day)
                |> NaiveDateTime.truncate(:second),
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 1, :day)
                |> NaiveDateTime.add(2, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location
            }
          ]
        }
        |> Repo.insert!()

        %Activity{
          title: "Test Activity 4",
          description: "This is a test activity",
          sessions: [
            %{
              minimum_entries: 0,
              maximum_entries: 10,
              enrolled: 0,
              start:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 2, :day)
                |> NaiveDateTime.truncate(:second),
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 2, :day)
                |> NaiveDateTime.add(2, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location
            }
          ]
        }
        |> Repo.insert!()

        %Activity{
          title: "Test Activity 5",
          description: "This is a test activity",
          sessions: [
            %{
              minimum_entries: 0,
              maximum_entries: 10,
              enrolled: 0,
              start:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 3, :day)
                |> NaiveDateTime.truncate(:second),
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 3, :day)
                |> NaiveDateTime.add(2, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location
            }
          ]
        }
        |> Repo.insert!()

        %Activity{
          title: "Test Activity 6",
          description: "This is a test activity",
          sessions: [
            %{
              minimum_entries: 0,
              maximum_entries: 10,
              enrolled: 0,
              start:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 4, :day)
                |> NaiveDateTime.truncate(:second),
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 4, :day)
                |> NaiveDateTime.add(2, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location
            }
          ]
        }
        |> Repo.insert!()

        %Activity{
          title: "Test Activity 7",
          description: "This is a test activity",
          sessions: [
            %{
              minimum_entries: 0,
              maximum_entries: 10,
              enrolled: 0,
              start:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 5, :day)
                |> NaiveDateTime.truncate(:second),
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 5, :day)
                |> NaiveDateTime.add(2, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location
            }
          ]
        }
        |> Repo.insert!()

        %Activity{
          title: "Test Activity 8",
          description: "This is a test activity",
          sessions: [
            %{
              minimum_entries: 0,
              maximum_entries: Enum.random(10..50),
              enrolled: 0,
              start:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 6, :day)
                |> NaiveDateTime.truncate(:second),
              finish:
                NaiveDateTime.add(NaiveDateTime.utc_now(), 6, :day)
                |> NaiveDateTime.add(2, :hour)
                |> NaiveDateTime.truncate(:second),
              location: location
            }
          ]
        }
        |> Repo.insert!()

      _ ->
        Mix.shell().error("Found activities, aborting seeding activities.")
    end
  end

  def seed_activities_departments do
    case Repo.all(SessionDepartment) do
      [] ->
        department = Repo.get_by(Department, name: "Merchandise and Partnerships")
        activities = Repo.all(Activity)

        for activity <- activities do
          %SessionDepartment{}
          |> SessionDepartment.changeset(%{
            activity_id: activity.id,
            department_id: department.id
          })
          |> Repo.insert!()
        end

      _ ->
        Mix.shell().error("Found session departments, aborting seeding session departments.")
    end
  end

  def seed_enrollments do
    case Repo.all(Enrollment) do
      [] ->
        users = Repo.all(User)
        sessions = Repo.all(Session)

        for user <- users do
          for _ <- 1..Enum.random(1..2) do
            Activities.create_enrollment(
              Enum.random(sessions).id,
              user
            )
          end
        end

      _ ->
        Mix.shell().error("Found enrollments, aborting seeding enrollments.")
    end
  end

  def seed_session_departments do
    case Repo.all(SessionDepartment) do
      [] ->
        department = Repo.get_by(Department, name: "CAOS")
        sessions = Repo.all(Session)

        for session <- sessions do
          %SessionDepartment{}
          |> SessionDepartment.changeset(%{
            session_id: session.id,
            department_id: department.id
          })
          |> Repo.insert!()
        end

      _ ->
        Mix.shell().error("Found session departments, aborting seeding session departments.")
    end
  end
end

Atomic.Repo.Seeds.Activities.run()
