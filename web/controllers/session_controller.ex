defmodule Rumbl.SessionController do
  use Rumbl.Web, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case Rumbl.Auth.login_by_username_and_password(conn, username, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Whoops! The username or password you entered is wrong.")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Rumbl.Auth.logout()
    |> put_flash(:info, "Come back soon!")
    |> redirect(to: page_path(conn, :index))
  end
end
