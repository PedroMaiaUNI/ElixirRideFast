defmodule RideFast.Accounts.Driver do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drivers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :status, :string, default: "INACTIVE"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(driver, attrs) do
    driver
    |> cast(attrs, [:name, :email, :phone, :password_hash, :status])
    |> validate_required([:name, :email, :phone, :password_hash, :status])
    |> validate_inclusion(:status, ["ACTIVE", "INACTIVE"])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end
