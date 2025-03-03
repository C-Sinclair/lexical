defmodule Lexical.RemoteControl.Build.Document.Compilers.Elixir do
  @moduledoc """
  A compiler for elixir source files (.ex and .exs)
  """

  alias Elixir.Features
  alias Lexical.Document
  alias Lexical.RemoteControl.Build
  alias Lexical.RemoteControl.Build.Document.Compilers

  @behaviour Build.Document.Compiler
  @valid_extensions ~w(.ex .exs)

  def recognizes?(%Document{} = doc) do
    Path.extname(doc.path) in @valid_extensions
  end

  def enabled? do
    true
  end

  def compile(%Document{} = document) do
    case to_quoted(document) do
      {:ok, quoted} ->
        Compilers.Quoted.compile(document, quoted, "Elixir")

      {:error, {meta, message_info, token}} ->
        diagnostics = Build.Error.parse_error_to_diagnostics(document, meta, message_info, token)
        {:error, diagnostics}
    end
  end

  defp to_quoted(document) do
    source_string = Document.to_string(document)
    parser_options = [file: document.path] ++ parser_options()
    Code.put_compiler_option(:ignore_module_conflict, true)
    Code.string_to_quoted(source_string, parser_options)
  end

  defp parser_options do
    [columns: true, token_metadata: true]
  end
end
