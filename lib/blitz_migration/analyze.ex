defmodule BlitzMigration.Analyze do
  @opts_definition NimbleOptions.new!([
    verbose: [
      type: :boolean,
      default: false,
      doc: "A flag to enable detailed logging during execution"
    ],
    skip_locked: [
      type: :boolean,
      default: false,
      doc: "A flag to enable skipping over relations with conflicting locks or relations that can't immediately be locked"
    ],
    columns: [
      type: {:list, :string},
      doc: "A list of columns on the table that will be analyzed"
    ]
  ])

  def execute(table_name, unchecked_opts) do
    with {:ok, opts} <- NimbleOptions.validate(unchecked_opts, @opts_definition),
         params <- sql_params(opts)
    do
      Ecto.Migration.execute(
        """
        ANALYZE #{params[:verbose]} #{params[:skip_locked]} 
        #{table_name} #{params[:columns]}
        """,
        ""
      )
    end
  end
  
  defp sql_params(opts) do
    default = %{
      verbose: "",
      skip_locked: "",
      columns: ""
    }

    opts
    |> handle_opt_combinations()
    |> Enum.reduce(default, fn 
        {:verbose, true}, acc -> %{acc | verbose: "VERBOSE"}
        {:skip_locked, true}, acc -> %{acc | skip_locked: "SKIP_LOCKED"}
        {:both, true}, acc -> %{acc | verbose: "(VERBOSE TRUE,", skip_locked: "SKIP_LOCKED TRUE)"}
        {:columns, columns}, acc -> %{acc | columns: "(#{Enum.join(columns, ", ")})"}
        {_, _}, acc -> acc
      end)
  end

  defp handle_opt_combinations(opts) do
    case Keyword.split(opts, [:verbose, :skip_locked]) do
      {args, opts} when length(args) === 2 -> Keyword.put(opts, :both, true)
      _ -> opts 
    end
  end
end
