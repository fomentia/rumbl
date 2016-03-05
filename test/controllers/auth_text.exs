defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase

  alias Rumbl.Auth

  setup %{conn: conn} do
    conn = conn
    |> bypass_through(Rumbl.Router, :browser)
    |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user does not halt when current_user exists", %{conn: conn} do
    conn = conn
    |> assign(:current_user, %Rumbl.User{})
    |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    conn = conn
    |> Auth.login(%Rumbl.User{id: 123})
    |> send_resp(:ok, "")

    next_conn = get(conn, "/")
    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    conn = conn
    |> put_session(:user_id, 123)
    |> Auth.logout()
    |> send_resp(:ok, "")

    next_conn = get(conn, "/")
    refute get_session(next_conn, :user_id) == 123
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn = conn
    |> put_session(:user_id, user.id)
    |> Auth.call(Rumbl.Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user to nil", %{conn: conn} do
    conn = Auth.call(conn, Rumbl.Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with valid username and password", %{conn: conn} do
    user = insert_user(username: "hackerman", password: "secretstuff")
    {:ok, conn} = Auth.login_by_username_and_password(conn, "hackerman", "secretstuff", repo: Rumbl.Repo)
    assert conn.assigns.current_user.id == user.id
  end

  test "log in with a not_found user", %{conn: conn} do
    assert {:error, :not_found, conn} == Auth.login_by_username_and_password(conn, "hackerman", "secretstuff", repo: Rumbl.Repo)
  end

  test "log in with an invalid password", %{conn: conn} do
    insert_user(username: "hackerman", password: "supersecret")
    assert {:error, :unauthorized, conn} == Auth.login_by_username_and_password(conn, "hackerman", "heyjude", repo: Rumbl.Repo)
  end
end
