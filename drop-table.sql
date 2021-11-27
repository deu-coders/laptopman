-- Truncate all tables (Optional)
BEGIN
    FOR c1 IN (SELECT y1.table_name, y1.constraint_name FROM user_constraints y1, user_tables x1 WHERE x1.table_name = y1.table_name ORDER BY y1.r_constraint_name nulls LAST) LOOP
        BEGIN
            dbms_output.put_line('alter table '||c1.table_name||' disable constraint '||c1.constraint_name || ';');
            execute immediate  ('alter table '||c1.table_name||' disable constraint '||c1.constraint_name);
        END;
    END LOOP;

    FOR t1 IN (SELECT table_name FROM user_tables) LOOP
        BEGIN
            dbms_output.put_line('truncate table '||t1.table_name || ';');    
            execute immediate ('truncate table '||t1.table_name);
        END;
    END LOOP;

    FOR c2 IN (SELECT y2.table_name, y2.constraint_name FROM user_constraints y2, user_tables x2 WHERE x2.table_name = y2.table_name ORDER BY y2.r_constraint_name nulls FIRST) LOOP
        BEGIN
            dbms_output.put_line('alter table '||c2.table_name||' enable constraint '||c2.constraint_name || ';');        
            execute immediate ('alter table '||c2.table_name||' enable constraint '||c2.constraint_name);
        END;
    END LOOP;
END;



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