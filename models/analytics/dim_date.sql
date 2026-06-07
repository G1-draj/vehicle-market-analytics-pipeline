-- dim_date: one row per unique posting date
-- derived from craigslist listing dates
-- enables time based analysis in Power BI

with craig as (
    select * from {{ ref('stg_craigslist_vehicles') }}
),

dates as (
    select distinct
        cast(posting_date as date)  as date_day
    from craig
    where posting_date is not null
),

dim as (
    select
        {{ dbt_utils.generate_surrogate_key(['date_day']) }}
                                as date_key,
        date_day                as full_date,
        year(date_day)          as year,
        month(date_day)         as month_number,
        monthname(date_day)     as month_name,
        day(date_day)           as day_of_month,
        dayname(date_day)       as day_name,
        quarter(date_day)       as quarter,
        case
            when dayname(date_day) in ('Sat', 'Sun')
            then true else false
        end                     as is_weekend
    from dates
)

select * from dim