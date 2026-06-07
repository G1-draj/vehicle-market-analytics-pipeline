-- dim_location: one row per unique state
-- enriched with region grouping for dashboard filtering

with craig as (
    select * from {{ ref('stg_craigslist_vehicles') }}
),

dim as (
    select distinct
        {{ dbt_utils.generate_surrogate_key(['state_code']) }}
                        as location_key,
        state_code,
        case
            when state_code in ('me','nh','vt','ma','ri','ct','ny','nj','pa')
                then 'Northeast'
            when state_code in ('oh','mi','in','il','wi','mn','ia','mo','nd','sd','ne','ks')
                then 'Midwest'
            when state_code in ('de','md','dc','va','wv','nc','sc','ga','fl','ky','tn','al','ms','ar','la','ok','tx')
                then 'South'
            when state_code in ('mt','id','wy','co','nm','az','ut','nv','ca','or','wa','ak','hi')
                then 'West'
            else 'Unknown'
        end as region
    from craig
    where state_code is not null
)

select * from dim