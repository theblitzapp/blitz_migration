defmodule BlitzMigration.Index do
  @opts_definition NimbleOptions.new!([
    unique: [
      type: :boolean,
      default: false,
      doc: "A flag to identify whether an index will be unique or not"
    ],
    concurrently: [
      type: :boolean,
      default: false,
      doc: "A flag to enable or disable concurrent index creation"
    ],
    if_not_exists: [
      type: :boolean,
      default: false,
      doc: "A flag to enable skipping index creation if the same name index exists"
    ],
    using: [
      type: :string,
      doc: "Specifies the type used when building an index, default is B-tree"
    ],
    columns: [
      type: {:list, :string},
      doc: "A list of columns used for the index. Can also use valid sql expressions",
      required: true
    ],
    include: [
      type: {:list, :string},
      doc: "A list of columns that can be added to an index as part of the INCLUDES clause"
    ],
    with: [
      type: :string,
      doc: "Specifies storage parameters for the index, specific to its type"
    ],
    tablespace: [
      type: :string,
      doc: "Specifies the tablespace where the index will reside"
    ],
    where: [
      type: :string,
      doc: "A limited where clause that can be used when defining an index"
    ]
  ])

  import Ecto.Migration, only: [execute: 2]

  def create(table_name, index_name, unchecked_opts) do
    with {:ok, opts} <- NimbleOptions.validate(unchecked_opts, @opts_definition),
         params <- sql_params(opts)
    do
      up_sql = 
        """
        CREATE #{params[:unique]} INDEX #{params[:concurrently]} 
        #{params[:if_not_exists]} #{index_name} ON #{table_name}
        """

      down_sql = 
        """
        DROP INDEX #{index_name} 
        """

      up_sql 
      |> append_clauses(opts)
      |> execute(down_sql)
    end
  end

  defp sql_params(opts) do
    default = %{
      unique: "",
      concurrently: "",
      if_not_exists: ""
    }

    Enum.reduce(opts, default, fn 
      {:unique, true}, acc -> %{acc | unique: "UNIQUE"}
      {:concurrently, true}, acc -> %{acc | concurrently: "CONCURRENTLY"}
      {:if_not_exists, true}, acc -> %{acc | if_not_exists: "IF NOT EXISTS"}
      {_, _}, acc -> acc
    end)
  end

  @clause_order [:using, :columns, :include, :with, :tablespace, :where]

  defp append_clauses(sql, opts) do
    opts
    |> Enum.sort_by(&get_order(@clause_order, &1))
    |> Enum.reduce([sql], fn 
        {:using, using}, acc -> ["USING #{using}" | acc]
        {:columns, columns}, acc -> ["(#{Enum.join(columns, ", ")})" | acc]
        {:include, includes}, acc -> ["INCLUDE (#{Enum.join(includes, ", ")})" | acc]
        {:with, with}, acc -> ["WITH (#{with})" | acc]
        {:tablespace, table_space}, acc -> ["TABLESPACE #{table_space}" | acc]
        {:where, where}, acc  -> ["WHERE #{where}" | acc]
        _, acc -> acc
      end)
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp get_order(key_ordering, {key, _}), do:
    Enum.find_index(key_ordering, & &1 === key)
end
