with source as (
    select * from {{ source('raw', 'craigslist_vehicles') }}
),

cleaned as (
    select
        year                as model_year,
        manufacturer        as manufacturer,
        model               as model_name,
        condition           as vehicle_condition,
        odometer            as odometer_miles,
        price               as listing_price,
        fuel                as fuel_type,
        transmission        as transmission,
        drive               as drive_type,
        state               as state_code,
        title_status        as title_status,
        try_to_timestamp(posting_date) as posting_date,
        lower(transmission) as transmission_type,
        case
            when lower(fuel) like '%gas%' then 'gas'
            when lower(fuel) like '%diesel%' then 'diesel'
            when lower(fuel) like '%electric%' then 'electric'
            when lower(fuel) like '%hybrid%' then 'electric'
            when lower(fuel) like '%other%' then 'other'
            else 'other'
        end as fuel_normalized
    from source
    where price > 0
      and price < 500000
      and year >= 1980
      and year <= 2027
      and odometer_miles >= 0
)

select * from cleaned