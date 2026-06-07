-- dim_vehicle: one row per unique vehicle make/model/year combination
-- sourced from EPA data which has official vehicle specifications

with epa as (
    select * from {{ ref('stg_epa_vehicles') }}
),

deduped as (
    select
        vehicle_id,
        manufacturer,
        model_name,
        model_year,
        vehicle_class,
        drive_type,
        transmission,
        transmission_type,
        cylinders,
        engine_displacement,
        vehicle_type,
        row_number() over (
            partition by manufacturer, model_name, model_year,
                         engine_displacement, 
                         vehicle_class, drive_type, transmission_type
            order by vehicle_id
        ) as rn
    from epa
    where manufacturer is not null
      and model_name is not null
      and model_year is not null
),

dim as (
    select
        {{ dbt_utils.generate_surrogate_key(['manufacturer', 'model_name', 'model_year', 'engine_displacement', 'vehicle_class', 'drive_type', 'transmission_type']) }}
                            as vehicle_key,
        manufacturer,
        model_name,
        model_year,
        vehicle_class,
        drive_type,
        transmission,
        transmission_type,
        cylinders,
        engine_displacement,
        vehicle_type
    from deduped
    where rn = 1
)

select * from dim