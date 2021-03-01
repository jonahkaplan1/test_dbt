











with pageviews_sessionized as (

    select * from `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`segment_web_page_views__sessionized`

    

),

referrer_mapping as (

    select * from `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`referrer_mapping`

),

agg as (

    select distinct

        session_id,
        anonymous_id,
        min(tstamp) over ( partition by session_id ) as session_start_tstamp,
        max(tstamp) over ( partition by session_id ) as session_end_tstamp,
        count(*) over ( partition by session_id ) as page_views,

        
        first_value(utm_source) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as utm_source,
        
        first_value(utm_content) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as utm_content,
        
        first_value(utm_medium) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as utm_medium,
        
        first_value(utm_campaign) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as utm_campaign,
        
        first_value(utm_term) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as utm_term,
        
        first_value(gclid) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as gclid,
        
        first_value(page_url) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as first_page_url,
        
        first_value(page_url_host) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as first_page_url_host,
        
        first_value(page_url_path) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as first_page_url_path,
        
        first_value(page_url_query) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as first_page_url_query,
        
        first_value(referrer) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as referrer,
        
        first_value(referrer_host) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as referrer_host,
        
        first_value(device) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as device,
        
        first_value(device_category) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as device_category,
        

        
        last_value(page_url) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as last_page_url,
        
        last_value(page_url_host) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as last_page_url_host,
        
        last_value(page_url_path) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as last_page_url_path,
        
        last_value(page_url_query) over (
    partition by session_id
    order by page_view_number
    rows between unbounded preceding and unbounded following
    ) as last_page_url_query
        

    from pageviews_sessionized

),

diffs as (

    select

        *,

        

    datetime_diff(
        cast(session_end_tstamp as datetime),
        cast(session_start_tstamp as datetime),
        second
    )

 as duration_in_s

    from agg

),

tiers as (

    select

        *,

        case
            when duration_in_s between 0 and 9 then '0s to 9s'
            when duration_in_s between 10 and 29 then '10s to 29s'
            when duration_in_s between 30 and 59 then '30s to 59s'
            when duration_in_s > 59 then '60s or more'
            else null
        end as duration_in_s_tier

    from diffs

),

mapped as (

    select
        tiers.*,
        referrer_mapping.medium as referrer_medium,
        referrer_mapping.source as referrer_source

    from tiers

    left join referrer_mapping on tiers.referrer_host = referrer_mapping.host

)

select * from mapped