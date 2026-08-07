-- ============================================================================
-- METHOD 1: The Modern Way (PostgreSQL 13 or newer)
-- ============================================================================
-- If you are trying to DROP the database and are running Postgres 13+, 
-- you can simply add the FORCE option. This automatically terminates 
-- all active connections and drops the database in a single command.

-- DROP DATABASE ejabberd WITH (FORCE);


-- ============================================================================
-- METHOD 2: Manual Termination (For older versions or RENAME operations)
-- ============================================================================
-- If you are renaming the database, or are on an older Postgres version,
-- follow these 3 steps to lock out connections, terminate current ones, and run your command.

-- STEP 1: Revoke connection privileges temporarily
-- This prevents new clients/services from reconnecting while we kill current ones.
ALTER DATABASE ejabberd WITH ALLOW_CONNECTIONS = false;


-- STEP 2: Forcefully terminate all current active connections to "ejabberd"
-- This query excludes your current query's PID (pg_backend_pid) to avoid self-termination.
SELECT 
    pg_terminate_backend(pid)
FROM 
    pg_stat_activity
WHERE 
    datname = 'ejabberd' 
    AND pid <> pg_backend_pid();


-- STEP 3: Perform your database operation
-- Now that connections are cleared, you can safely drop or rename it:

-- Option A: Drop the database
-- DROP DATABASE ejabberd;

-- Option B: Rename the database (Remember to allow connections again after renaming)
-- ALTER DATABASE ejabberd RENAME TO ejabberd_backup;
-- ALTER DATABASE ejabberd_backup WITH ALLOW_CONNECTIONS = true;
