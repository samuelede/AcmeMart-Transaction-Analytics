{% macro union_seeds(pattern) %}

{#
    Development macro: dynamically unions all dbt seed tables whose name
    contains the given pattern.

    Usage:
        {{ union_seeds('store') }}

    Matches seed files named like:
        store_S001.csv
        store_S002.csv
        store_5_25-01.csv
        store_S003.csv  etc.

    NOTE: In production, this macro is bypassed and data is read directly
    from BRONZE.CSV_SALES loaded by Airbyte. See stg_transactions.sql
    for the commented-out production source block.
#}

{%- set seed_nodes = [] -%}

{%- for node in graph.sources.values() | list + graph.nodes.values() | list -%}
    {%- if node.resource_type == 'seed'
        and pattern | lower in node.name | lower -%}
        {%- do seed_nodes.append(node.name) -%}
    {%- endif -%}
{%- endfor -%}

{%- if seed_nodes | length == 0 -%}
    {{ exceptions.raise_compiler_error(
        "union_seeds: no seed tables found matching pattern '" ~ pattern ~ "'. "
        ~ "Make sure you have run `dbt seed` first."
    ) }}
{%- endif -%}

{%- for seed_name in seed_nodes -%}
    select * from {{ ref(seed_name) }}
    {%- if not loop.last %} union all {% endif %}
{%- endfor -%}

{% endmacro %}