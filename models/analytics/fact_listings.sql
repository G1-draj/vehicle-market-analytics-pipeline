-- fact_listings: one row per used car listing
-- joins craigslist market data with EPA vehicle specs
-- connects to all dimension tables via surrogate keys

with craig as (
    select * from {{ ref('stg_craigslist_vehicles') }}
),

epa as (
     select * from (
        select *,
            row_number() over (
                partition by manufacturer, model_name, model_year,
                             fuel_normalized, transmission_type
                order by vehicle_id
            ) as rn
        from {{ ref('stg_epa_vehicles') }}
    )epa_deduped  where rn = 1
),

vehicle_dim as (
    select * from {{ ref('dim_vehicle') }}
),

fuel_dim as (
    select * from {{ ref('dim_fuel') }}
),

location_dim as (
    select * from {{ ref('dim_location') }}
),

date_dim as (
    select * from {{ ref('dim_date') }}
),

fact as (
    select
        {{ dbt_utils.generate_surrogate_key(['c.manufacturer', 'c.model_name', 'c.model_year', 'c.listing_price', 'c.odometer_miles', 'c.posting_date']) }}
                                as listing_key,
        v.vehicle_key,
        f.fuel_key,
        l.location_key,
        d.date_key,
        c.listing_price,
        c.odometer_miles,
        c.vehicle_condition,
        c.transmission,
        c.title_status,
        e.mpg_city,
        e.mpg_highway,
        e.mpg_combined,
        e.annual_fuel_cost,
        e.savings_vs_average
    from craig c
    left join epa e
        on  upper(c.manufacturer)    = upper(e.manufacturer)
        and upper(c.model_name)      = upper(e.model_name)
        and c.model_year             = e.model_year
        and c.fuel_normalized        = e.fuel_normalized
        and c.transmission_type      = e.transmission_type
    left join vehicle_dim v
        on  upper(c.manufacturer)  = upper(v.manufacturer)
        and upper(c.model_name)    = upper(v.model_name)
        and c.model_year           = v.model_year
        and c.transmission_type      = v.transmission_type
    left join fuel_dim f
        on e.fuel_type             = f.fuel_type
        and e.fuel_economy_score   = f.fuel_economy_score
        and e.ghg_score            = f.ghg_score
    left join location_dim l
        on c.state_code            = l.state_code
    left join date_dim d
        on cast(c.posting_date as date) = d.full_date
    where c.transmission_type is not null
        and c.fuel_normalized is not null    
)

select * from fact