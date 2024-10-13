defmodule TcbWeb.Plugs.RemoveXFrameOptions do
  @x_frame_options "x-frame-options"

  def init(default), do: default

  def call(%Plug.Conn{} = conn, _default) do
    conn |> remove_x_frame_options_header()
  end

  defp remove_x_frame_options_header(%Plug.Conn{} = conn) do
    conn
    |> Map.update!(:resp_headers, fn headers ->
      headers
      |> Enum.filter(fn {key, _} ->
        key != @x_frame_options
      end)
    end)
  end
end
