defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase

  alias Rumbl.Repo
  alias Rumbl.User

  @valid_attrs %{name: "Hackerman", username: "hckrmn"}

  test "converts unique_constraint on username to error" do
    insert_user(username: "kungfoot")
    attrs = Map.put(@valid_attrs, :username, "kungfoot")
    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, "has already been taken"} in changeset.errors
  end
end

