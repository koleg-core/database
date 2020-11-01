DROP TRIGGER IF EXISTS trg_users_ins_upd ON users;
DROP TABLE IF EXISTS USERS_PWD_HISTORY;
DROP TABLE IF EXISTS USER_GROUPS;
DROP TABLE IF EXISTS USER_RIGHTS;
DROP TABLE IF EXISTS GROUP_RIGHTS;
DROP TABLE IF EXISTS RIGHTS;
DROP TABLE IF EXISTS GROUPS;
DROP TABLE IF EXISTS USER_PHONES;
DROP TABLE IF EXISTS PHONE_TYPE;
DROP TABLE IF EXISTS USERS;
DROP TABLE IF EXISTS JOBS;

CREATE TABLE IF NOT EXISTS JOBS (
    ID SERIAL PRIMARY KEY,
    NAME VARCHAR ( 500 )
);

CREATE TABLE IF NOT EXISTS USERS (
	ID SERIAL PRIMARY KEY,
    UUID VARCHAR(255) UNIQUE,
	FIRSTNAME VARCHAR ( 50 ),
    LASTNAME VARCHAR ( 50 ),
    USERNAME VARCHAR ( 50 ),
	PASSWORD VARCHAR ( 50 ),
    PASSWORD_DATELIMIT TIMESTAMP,
    BIRTHDATE TIMESTAMP,
	EMAIL VARCHAR ( 255 ),
    IMG_URL VARCHAR ( 255 ),
	SSH_KEY BYTEA,
    ID_JOB INTEGER,
    CREATION_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATE_DATE TIMESTAMP,
    EXPIRATION_DATE TIMESTAMP,
    CONSTRAINT FK_USERS_JOB
      FOREIGN KEY(ID_JOB) 
	  REFERENCES JOBS(ID)
      ON DELETE SET NULL --when deleting a job in the JOBS table, all the row referenced by this job in the USERS table are set to null
);

CREATE TABLE IF NOT EXISTS PHONE_TYPE (
    ID SERIAL PRIMARY KEY,
    NAME VARCHAR ( 500 )
);

CREATE TABLE IF NOT EXISTS USER_PHONES (
    ID_USER INTEGER,
    ID_PHONETYPE INTEGER,
    VALUE VARCHAR (500),
    CONSTRAINT FK_PHONES_USER
      FOREIGN KEY(ID_USER) 
	  REFERENCES USERS(ID)
      ON DELETE CASCADE, --when deleting a user in the USERS table, all the row referenced by this group in the USER_PHONES table are deleted
    CONSTRAINT FK_ID_PHONES_TYPE
      FOREIGN KEY(ID_PHONETYPE) 
	  REFERENCES PHONE_TYPE(ID)
      ON DELETE CASCADE --when deleting a phonetype in the PHONE_TYPE table, all the row referenced by this phonetype in the USER_PHONES table are deleted
);


CREATE TABLE IF NOT EXISTS USERS_PWD_HISTORY (
    ID SERIAL PRIMARY KEY,
    UPDATE_DATE TIMESTAMP,
    ID_USER INTEGER,
    PASSWORD VARCHAR ( 50 ),
    CONSTRAINT FK_ID_USER_PWD_HISTORY
      FOREIGN KEY(ID_USER) 
	  REFERENCES USERS(ID)
      ON DELETE CASCADE --when deleting a user in the USERS table, all the row referenced by this group in the USERS_PWD_HISTORY table are deleted
);

CREATE TABLE IF NOT EXISTS RIGHTS (
	ID SERIAL PRIMARY KEY,
	NAME VARCHAR ( 500 ),
    DESCRIPTION VARCHAR
);

CREATE TABLE IF NOT EXISTS USER_RIGHTS (
    ID_USER INTEGER,
    ID_RIGHT INTEGER,
    PRIMARY KEY (ID_USER, ID_RIGHT),
    CONSTRAINT FK_RIGHTS_USER
      FOREIGN KEY(ID_USER) 
	  REFERENCES USERS(ID)
      ON DELETE CASCADE, --when deleting a user in the USERS table, all the row referenced by this user in the USER_RIGHTS table are deleted
    CONSTRAINT FK_USERS_RIGHT
      FOREIGN KEY(ID_RIGHT) 
	  REFERENCES RIGHTS(ID)
      ON DELETE CASCADE --when deleting a right in the RIGHTS table, all the row referenced by this right in the USER_RIGHTS table are deleted
);

CREATE TABLE IF NOT EXISTS GROUPS (
	ID SERIAL PRIMARY KEY,
	NAME VARCHAR ( 500 ),
    DESCRIPTION VARCHAR
);

--define set of one or multiple rights for one or multiple groups.
CREATE TABLE IF NOT EXISTS GROUP_RIGHTS (
	ID_GROUP INTEGER,
    ID_RIGHT INTEGER,
    PRIMARY KEY (ID_GROUP, ID_RIGHT),
    CONSTRAINT FK_RIGHTS_GROUP
      FOREIGN KEY(ID_GROUP) 
	  REFERENCES GROUPS(ID)
      ON DELETE CASCADE, --when deleting a group in the GROUPS table, all the row referenced by this group in the GROUP_RIGHTS table are deleted
    CONSTRAINT FK_GROUPS_RIGHT
      FOREIGN KEY(ID_RIGHT) 
	  REFERENCES RIGHTS(ID)
      ON DELETE CASCADE --when deleting a right in the RIGHTS table, all the row referenced by this right in the GROUP_RIGHTS table are deleted
);

--define set of one or multiple groups for one or multple users.
CREATE TABLE IF NOT EXISTS USER_GROUPS (
	ID_USER INTEGER,
    ID_GROUP INTEGER,
    PRIMARY KEY (ID_USER, ID_GROUP),
    CONSTRAINT FK_GROUPS_USER
      FOREIGN KEY(ID_USER) 
	  REFERENCES USERS(ID)
      ON DELETE CASCADE, --when deleting a user in the USERS table, all the row referenced by this group in the GROUP_RIGHTS table are deleted
    CONSTRAINT FK_USERS_GROUP
      FOREIGN KEY(ID_GROUP) 
	  REFERENCES GROUPS(ID)
      ON DELETE CASCADE --when deleting a group in the RIGHTS table, all the row referenced by this group in the GROUP_RIGHTS table are deleted
);

CREATE OR REPLACE FUNCTION users_management() RETURNS trigger AS $trg_users_ins_upd$
    DECLARE
      V_MODIF BOOLEAN := FALSE;
      V_PASSWORD USERS.PASSWORD%TYPE;
    BEGIN
      -- Force lowercase email
      NEW.EMAIL := LOWER(NEW.EMAIL);
      
      IF TG_OP = 'UPDATE' THEN
        IF COALESCE (NEW.PASSWORD, '???') != COALESCE (OLD.PASSWORD, '???')
          THEN
            V_PASSWORD := COALESCE (OLD.PASSWORD, '???');
            V_MODIF := TRUE;
          END IF;
      END IF;
      IF V_MODIF THEN
        NEW.UPDATE_DATE := CURRENT_TIMESTAMP;
        INSERT INTO USERS_PWD_HISTORY(UPDATE_DATE,ID_USER,PASSWORD)
        VALUES(CURRENT_TIMESTAMP,NEW.ID,V_PASSWORD);
      END IF;
      RETURN NEW;
    END;
$trg_users_ins_upd$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_ins_upd BEFORE INSERT OR UPDATE ON USERS
    FOR EACH ROW EXECUTE PROCEDURE users_management();