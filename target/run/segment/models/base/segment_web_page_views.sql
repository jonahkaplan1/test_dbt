

  create or replace view `fivetran-data-culture-big-vv9p`.`dbt_jkaplan`.`segment_web_page_views`
  OPTIONS()
  as with source as (

    select * from dbt_jkaplan.pages

),

renamed as (

    select

        id as page_view_id,
        anonymous_id,
        user_id,

        received_at as received_at_tstamp,
        sent_at as sent_at_tstamp,
        timestamp as tstamp,

        url as page_url,
        
    safe_cast(

    split(
        

    split(
        

    replace(
        

    replace(
        url,
        'http://',
        ''
    )
    

,
        'https://',
        ''
    )
    

,
        '/'
        )[safe_offset(0)]

,
        '?'
        )[safe_offset(0)]

 as 
    string
)
 as page_url_host,
        path as page_url_path,
        title as page_title,
        search as page_url_query,

        referrer,
        replace(
            
    safe_cast(

    split(
        

    split(
        

    replace(
        

    replace(
        referrer,
        'http://',
        ''
    )
    

,
        'https://',
        ''
    )
    

,
        '/'
        )[safe_offset(0)]

,
        '?'
        )[safe_offset(0)]

 as 
    string
)
,
            'www.',
            ''
        ) as referrer_host,

        context_campaign_source as utm_source,
        context_campaign_medium as utm_medium,
        context_campaign_name as utm_campaign,
        context_campaign_term as utm_term,
        context_campaign_content as utm_content,
        nullif(

    split(
        

    split(
        url,
        'gclid='
        )[safe_offset(1)]

,
        '&'
        )[safe_offset(0)]

,'') as gclid,
        context_ip as ip,
        context_user_agent as user_agent,
        case
            when lower(context_user_agent) like '%android%' then 'Android'
            else replace(
                

    split(
        

    split(
        context_user_agent,
        '('
        )[safe_offset(1)]

,
        ' '
        )[safe_offset(0)]

,
                ';', '')
        end as device

        

    from source

),

final as (

    select
        *,
        case
            when device = 'iPhone' then 'iPhone'
            when device = 'Android' then 'Android'
            when device in ('iPad', 'iPod') then 'Tablet'
            when device in ('Windows', 'Macintosh', 'X11') then 'Desktop'
            else 'Uncategorized'
        end as device_category
    from renamed

)

select * from final;

