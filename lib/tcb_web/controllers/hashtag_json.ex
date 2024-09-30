defmodule TcbWeb.HashtagJSON do
  def index(%{hashtags: hashtags}) do
    for(hashtag <- hashtags, do: data(hashtag))
  end

  defp data(%Tcb.Hashtag{} = hashtag) do
    %{
      category: hashtag.category,
      name: hashtag.name
    }
  end
end
