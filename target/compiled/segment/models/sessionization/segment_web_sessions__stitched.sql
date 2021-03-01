

with sessions as (

    select * from `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`segment_web_sessions__initial`

    

),

id_stitching as (

    select * from `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`segment_web_user_stitching`

),

joined as (

    select

        sessions.*,

        coalesce(id_stitching.user_id, sessions.anonymous_id)
            as blended_user_id

    from sessions
    left join id_stitching using (anonymous_id)

)

select * from joined