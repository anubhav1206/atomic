defmodule AtomicWeb.UserSessionController do
  use AtomicWeb, :controller

  alias Atomic.Accounts
  alias AtomicWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params
    user = Accounts.get_user_by_email_and_password(email, password)

    if user do
      if is_nil(user.confirmed_at) do
        render(conn, "new.html", error_message: "Confirm your email before continuing")
      else
        UserAuth.log_in_user(conn, user, user_params)
      end
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
