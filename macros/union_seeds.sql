{% macro union_seeds(pattern) %}

{#
    Unions all seed tables listed under the 'seed_files' variable
    in dbt_project.yml whose name contains the given pattern.

    Add new seed filenames to the 'seed_files' var in dbt_project.yml
    and they will be automatically included on the next dbt run.

    Usage:
        {{ union_seeds('store') }}
#}

{%- set all_seeds = var('seed_files', []) -%}
{%- set matched = [] -%}

{%- for seed_name in all_seeds -%}
    {%- if pattern | lower in seed_name | lower -%}
        {%- do matched.append(seed_name) -%}
    {%- endif -%}
{%- endfor -%}

{%- if matched | length == 0 -%}
    {{ exceptions.raise_compiler_error(
        "union_seeds: no seeds found matching pattern '"
        ~ pattern ~ "'. "
        ~ "Add the seed filename to the 'seed_files' var in dbt_project.yml "
        ~ "and make sure you have run `dbt seed` first."
    ) }}
{%- endif -%}

{%- for seed_name in matched -%}
    select * from {{ ref(seed_name) }}
    {%- if not loop.last %} union all {% endif %}
{%- endfor -%}

{% endmacro %}