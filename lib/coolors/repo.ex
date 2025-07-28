defmodule Coolors.Repo do
  use Ecto.Repo,
    otp_app: :coolors,
    adapter: Ecto.Adapters.MyXQL
end
