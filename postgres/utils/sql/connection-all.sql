SELECT 
    pid,
    datname AS database_name,
    usename AS user_name,
    client_addr AS client_ip,
    backend_start AS connection_established,
    query_start AS query_started_at,
    now() - query_start AS query_duration,
    state,
    query
FROM 
    pg_stat_activity
WHERE 
    state = 'active'
    AND pid <> pg_backend_pid()
ORDER BY 
    query_start ASC;
