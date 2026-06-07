-- dim_fuel: one row per unique fuel type and EPA rating combination
-- sourced from EPA data which has official emissions and efficiency scores

with epa as (
    select * from {{ ref('stg_epa_vehicles') }}
),

deduped as (
    select
        fuel_type,
        fuel_economy_score,
        ghg_score,
        co2_grams_per_mile,
        annual_fuel_cost,
        savings_vs_average,
        row_number() over (
            partition by fuel_type, fuel_economy_score, ghg_score, co2_grams_per_mile
            order by fuel_economy_score desc
        ) as rn
    from epa
    where fuel_type is not null
),

dim as (
    select
        {{ dbt_utils.generate_surrogate_key(['fuel_type', 'fuel_economy_score', 'ghg_score', 'co2_grams_per_mile']) }}
                            as fuel_key,
        fuel_type,
        fuel_economy_score,
        ghg_score,
        co2_grams_per_mile,
        annual_fuel_cost,
        savings_vs_average
    from deduped
    where rn = 1
)

select * from dim