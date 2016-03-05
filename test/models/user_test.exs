defmodule Rumbl.UserTest do
  use Rumbl.ModelCase, async: true

  alias Rumbl.User

  import Comeonin

  @valid_attrs %{name: "Hackerman", username: "hckrmn", password: "ilovehax"}
  @invalid_attrs %{}

  test "changeset with valid attrs" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attrs" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid username" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
    assert {:username, {"should be at most %{count} character(s)", [count: 20]}} in errors_on(%User{}, attrs)
  end

  test "registration_changeset password at least 6 characters long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    changeset = User.registration_changeset(%User{}, attrs)
    assert {:password, {"should be at least %{count} character(s)", count: 6}} in changeset.errors
  end

  test "registration_changeset with valid attrs hashes password" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    %{password: password, password_hash: password_hash} = changeset.changes

    assert changeset.valid?
    assert password_hash
    assert Comeonin.Bcrypt.checkpw(password, password_hash)
  end
end

