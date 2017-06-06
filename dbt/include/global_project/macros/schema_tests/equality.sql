
{% macro test_equality(model, arg) %}

{% set schema = model.split('.')[0] %}
{% set model_a_name = model.split('.')[1] %}

{% set columns = adapter.get_columns_in_table(schema, model_a_name) %}
{% set cols_csv = dest_columns | map(attribute='quoted') | join(', ') %}

with a as (

    select * from {{ model }}

),

b as (

    select * from {{ arg }}

),

a_minus_b as (

    select cols_csv from a
    except
    select cols_csv from b

),

b_minus_a as (

    select cols_csv from b
    except
    select cols_csv from a

),

unioned as (

    select * from a_minus_b
    union all
    select * from b_minus_a

),

final as (

    select (select count(*) from unioned) +
        (select abs(
            (select count(*) from a_minus_b) -
            (select count(*) from b_minus_a)
            ))
        as count

)

select count from final

-- {{schema}}
-- {{model_a_name}}
-- {{model_b_name}}


{% endmacro %}
