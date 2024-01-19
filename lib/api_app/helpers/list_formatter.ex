defmodule ApiApp.Helpers.ListFormatter do
  def format_list(list) do
    "[#{Enum.join(Enum.map(list, &Integer.to_string/1), ", ")}]"
  end
end
