defmodule Coolors.Tools do
  @doc """
  Writes a term in a human-readable format.

  """
  def ii(o) do
    inspect(o,
      # No limit on collection size
      limit: :infinity,
      # No limit on string length
      printable_limit: :infinity,
      # No line width limit
      width: :infinity,
      # Pretty formatting
      pretty: true
    )
  end

  @doc """
  Generates the SVG image, as the data-encoded contents of
  the "img src" tag.



  """

  def pagelet_qr(url) when is_binary(url) do
    # See https://hexdocs.pm/qr_code/readme.html
    {:ok, qr_b64} =
      url
      |> QRCode.create(:high)
      |> QRCode.render()
      |> QRCode.to_base64()

    "data:image/svg+xml;base64,#{qr_b64}"
  end

  def pubsub_channel(pageletId), do: "pagelet_#{pageletId}"
end
