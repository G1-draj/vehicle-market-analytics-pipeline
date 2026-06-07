with source as (
    select * from {{ source('raw', 'epa_vehicles') }}
),

renamed as (
    select
        id                  as vehicle_id,
        year                as model_year,
        make                as manufacturer,
        model               as model_name,
        vclass              as vehicle_class,
        drive               as drive_type,
        trany               as transmission,
        fueltype            as fuel_type,
        cylinders           as cylinders,
        displ               as engine_displacement,
        city08              as mpg_city,
        highway08           as mpg_highway,
        comb08              as mpg_combined,
        co2tailpipegpm      as co2_grams_per_mile,
        fescore             as fuel_economy_score,
        ghgscore            as ghg_score,
        fuelcost08          as annual_fuel_cost,
        yousavespend        as savings_vs_average,
        atvtype             as vehicle_type,
        case
            when lower(trany) like 'automatic%' then 'automatic'
            when lower(trany) like 'manual%' then 'manual'
            else 'other'
        end as transmission_type,

        case
            when lower(fueltype) like '%regular%' then 'gas'
            when lower(fueltype) like '%premium%' then 'gas'
            when lower(fueltype) like '%electricity%' then 'electric'
            when lower(fueltype) like '%diesel%' then 'diesel'
            when lower(fueltype) like '%e85%' then 'flex'
            when lower(fueltype) like '%natural gas%' then 'cng'
            else 'other'
        end as fuel_normalized
    from source
)

select * from renamed