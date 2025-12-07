defmodule RideFast.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :rides, RideFast.Rides.Ride

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone, :password])
    |> validate_required([:name, :email, :phone])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, error: 409)
    |> validate_password?()
  end

  def create_changeset(user, attrs) do
    user
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
