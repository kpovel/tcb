defmodule TcbWeb.HashtagJSON do
  def index(%{hashtags: hashtags}) do
    hashtags
    |> Enum.reduce([], fn %Tcb.Hashtag{} = hashtag, acc ->
      case List.first(acc) do
        nil ->
          [%{name: hashtag.category, hashtags: [%{id: hashtag.hashtag_id, name: hashtag.name}]}]

        %{name: name} when name == hashtag.category ->
          List.update_at(acc, 0, fn res ->
            Map.update!(res, :hashtags, fn hashtags ->
              hashtags ++ [%{id: hashtag.hashtag_id, name: hashtag.name}]
            end)
          end)

        _ ->
          [
            %{name: hashtag.category, hashtags: [%{id: hashtag.hashtag_id, name: hashtag.name}]}
            | acc
          ]
      end
    end)
    |> Enum.reverse()
  end
end
