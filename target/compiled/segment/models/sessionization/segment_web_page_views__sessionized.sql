



with pageviews as (

    select * from `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`segment_web_page_views`

    

),

numbered as (

    --This CTE is responsible for assigning an all-time page view number for a
    --given anonymous_id. We don't need to do this across devices because the
    --whole point of this field is for sessionization, and sessions can't span
    --multiple devices.

    select

        *,

        row_number() over (
            partition by anonymous_id
            order by tstamp
            ) as page_view_number

    from pageviews

),

lagged as (

    --This CTE is responsible for simply grabbing the last value of `tstamp`.
    --We'll use this downstream to do timestamp math--it's how we determine the
    --period of inactivity.

    select

        *,

        lag(tstamp) over (
            partition by anonymous_id
            order by page_view_number
            ) as previous_tstamp

    from numbered

),

diffed as (

    --This CTE simply calculates `period_of_inactivity`.

    select
        *,
        

    datetime_diff(
        cast(tstamp as datetime),
        cast(previous_tstamp as datetime),
        second
    )

 as period_of_inactivity
    from lagged

),

new_sessions as (

    --This CTE calculates a single 1/0 field--if the period of inactivity prior
    --to this page view was greater than 30 minutes, the value is 1, otherwise
    --it's 0. We'll use this to calculate the user's session #.

    select
        *,
        case
            when period_of_inactivity <= 30 * 60 then 0
            else 1
        end as new_session
    from diffed

),

session_numbers as (

    --This CTE calculates a user's session (1, 2, 3) number from `new_session`.
    --This single field is the entire point of the entire prior series of
    --calculations.

    select

        *,

        sum(new_session) over (
            partition by anonymous_id
            order by page_view_number
            rows between unbounded preceding and current row
            ) as session_number

    from new_sessions

),

session_ids as (

    --This CTE assigns a globally unique session id based on the combination of
    --`anonymous_id` and `session_number`.

    select

        `page_view_id`,
  `anonymous_id`,
  `user_id`,
  `received_at_tstamp`,
  `sent_at_tstamp`,
  `tstamp`,
  `page_url`,
  `page_url_host`,
  `page_url_path`,
  `page_title`,
  `page_url_query`,
  `referrer`,
  `referrer_host`,
  `utm_source`,
  `utm_medium`,
  `utm_campaign`,
  `utm_term`,
  `utm_content`,
  `gclid`,
  `ip`,
  `user_agent`,
  `device`,
  `device_category`,
        page_view_number,
        to_hex(md5(cast(concat(coalesce(cast(anonymous_id as 
    string
), ''), '-', coalesce(cast(session_number as 
    string
), '')) as 
    string
))) as session_id

    from session_numbers

)

select * from session_ids