

  create or replace table `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`segment_web_sessions`
  
  
  OPTIONS()
  as (
    





with sessions as (

    select * from `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`segment_web_sessions__stitched`

    

),



windowed as (

    select

        *,

        row_number() over (
            partition by blended_user_id
            order by sessions.session_start_tstamp
            )
            
            as session_number

    from sessions

    


)

select * from windowed
  );
  