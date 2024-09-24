defmodule TcbWeb.UserJSON do
  def onboarding_data(%{data: data}), do: data

  def about_too_long(%{fieldMessage: fieldMessage}) do
    %{fieldName: "", fieldMessage: fieldMessage}
  end
end
