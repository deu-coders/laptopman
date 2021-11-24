-- Drop all tables and related constaints
BEGIN
    FOR C IN (
        SELECT 'DROP TABLE ' || TABLE_NAME || ' CASCADE CONSTRAINTS' "QUERY_STR"
        FROM USER_TABLES
    )
    LOOP
        EXECUTE IMMEDIATE C.QUERY_STR;
    END LOOP;
END;