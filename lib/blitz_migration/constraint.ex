defmodule BlitzMigration.Constraint do
  @opts_definition NimbleOptions.new!([
    not_valid: [
      type: :boolean,
      doc: "A flag to enable or disable constraint validations on existing rows"
    ],
    check: [
      type: :string,
      doc: "Mutually Exclusive - defines a check constraint for a table given an expression"
    ],
    unique: [
      type: {:list, :string},
      doc: "Mutually Exclusive - defines a unique constraint for a table given a set of fields"
    ],
    exclude: [
      type: :string,
      doc: "Mutually Exclusive - defines an exclusive constraint for a table given an expression beginning with \"USING\""
    ],
    foreign: [
      type: :keyword_list,
      doc: "Mutually Exclusive - defines a foreign key constraint for a table given the appropriate parameters",
      keys: [
        key: [
          type: {:or, [:string, {:list, :string}]},
          doc: "The keys on the target table to associate as the foreign key"
        ], 
        ref_table: [
          type: :string,
          doc: "The reference table."
        ],
        ref_key: [
          type: {:or, [:string, {:list, :string}]},
          doc: "The keys on the reference table to associate as the foreign key"
        ], 
        on_delete: [
          type: :string,
          default: "CASCADE",
          doc: "The action taken when a row in the reference table is deleted"
        ],
        on_update: [
          type: :string,
          default: "CASCADE",
          doc: "The action taken when a row in the reference table is updated"
        ]
      ]
    ]
  ])

  @moduledoc """
  A feature rich helper module for working with constraints in migrations file or with the Ecto.Migrator
  Works with the change callback in Ecto.Migrations, providing both up and down functionality
  The options are defined below:
  #{NimbleOptions.docs(@opts_definition)}
  """
  import Ecto.Migration, only: [execute: 2]

  def create(table_name, constraint_name, unchecked_opts) do
    with {:ok, opts} <- NimbleOptions.validate(unchecked_opts, @opts_definition) do
      up_sql = 
        """
        ALTER TABLE #{table_name}
        ADD CONSTRAINT #{constraint_name}
        """

      down_sql = 
        """
        ALTER TABLE #{table_name} 
        DROP CONSTRAINT #{constraint_name}
        """

      up_sql 
      |> append_clause(opts)
      |> append_validity(opts)
      |> execute(down_sql)
    end
  end

  defp append_clause(sql, opts) do
    clause = 
      cond do
        check = opts[:check] -> "CHECK (#{check})"
        exclude = opts[:exclude] -> "EXCLUDE #{exclude}"
        unique = opts[:unique] -> "UNIQUE (#{Enum.join(unique, ", ")})"
        foreign = opts[:foreign] -> 
          foreign
          |> format_fkey_params()
          |> fkey_clause()
      end

    """
    #{sql}
    #{clause}
    """
  end

  defp format_fkey_params(params) do
    default = %{
      on_delete: "CASCADE",
      on_update: "CASCADE"
    }

    Enum.reduce(params, default, fn 
      {:key, key}, acc when is_list(key) -> Map.put(acc, :key, key)
      {:ref_key, rkey}, acc when is_list(rkey) -> Map.put(acc, :ref_key, rkey)
      {:key, key}, acc -> Map.put(acc, :key, [key])
      {:ref_key, rkey}, acc -> Map.put(acc, :ref_key, [rkey])
      {:ref_table, ref}, acc -> Map.put(acc, :ref_table, ref)
      {:on_delete, delete}, acc -> Map.put(acc, :ref_table, delete)
      {:on_update, update}, acc -> Map.put(acc, :ref_table, update)
      _, acc -> acc
    end)
  end

  defp fkey_clause(%{
      key: key, 
      ref_table: ref_table, 
      ref_key: ref_key,
      on_delete: on_delete,
      on_update: on_update
    }) 
  do
    """
    FOREIGN KEY (#{Enum.join(key, ", ")})
    REFERENCES #{ref_table} (#{Enum.join(ref_key, ", ")})
    ON DELETE #{on_delete}
    ON UPDATE #{on_update}
    """
  end

  defp append_validity(sql, opts) do
    case Keyword.get(opts, :not_valid) do
      true -> 
        """
        #{sql}
        NOT VALID
        """
      _ -> sql
    end
  end
end
