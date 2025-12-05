defmodule RideFast.Accounts.Driver do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drivers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :status, :string, default: "INACTIVE"
    field :password_hash, :string
    field :password, :string, virtual: true

    timestamps()
  end

  def changeset(driver, attrs) do
    driver
    |> cast(attrs, [:name, :email, :phone, :status, :password])
    |> validate_required([:name, :email, :phone])
    |> validate_inclusion(:status, ["ACTIVE", "INACTIVE"])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_password?()
  end

  def create_changeset(driver, attrs) do
    driver
    |> changeset(attrs)
    |> validate_required([:password])
  end

  defp validate_password?(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      _password ->
        changeset
        |> validate_length(:password, min: 8)
        |> put_password_hash()
    end
  end

  defp put_password_hash(changeset) do
    password = get_change(changeset, :password)
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end
end
