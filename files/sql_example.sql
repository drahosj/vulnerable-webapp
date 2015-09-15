-- This is an INSERT statement
-- It creates a user JOE that is not an admin
INSERT INTO users VALUES ('Joe', FALSE);

-- This is a select statement. It selects all of the admin users
SELECT name FROM users WHERE admin=TRUE;

-- This gets the admin status of Alice
SELECT admin FROM users WHERE name='Alice';
