defmodule LunaConnect.CLI do
  @moduledoc """
  Defines the CLI interface.
  """

  alias LunaConnect.Configuration

  @doc """
  Main function for the escript.
  """
  def main(["gh" | _]) do
    _config = Configuration.read_config()
    IO.puts("Here we are.\n")
  end

  def main(["config" | _]) do
    config = Configuration.read_config()
    IO.puts("#{inspect(config, pretty: true)}")
  end

  def main(_) do
    IO.puts("""
    luco gh - Import open GH issues assigned to @me
    """)
  end
end
