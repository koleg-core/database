--
-- PostgreSQL database dump
--

-- Dumped from database version 11.9
-- Dumped by pg_dump version 13.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE postgres;
--
-- Name: postgres; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


ALTER DATABASE postgres OWNER TO postgres;

\connect postgres

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: users_gestion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.users_gestion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
      V_MODIF BOOLEAN := FALSE;
      V_PASSWORD USERS.PASSWORD%TYPE;
    BEGIN
      -- Forcer email en minuscule
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
$$;


ALTER FUNCTION public.users_gestion() OWNER TO postgres;

--
-- Name: users_management(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.users_management() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    V_MODIF BOOLEAN := FALSE;
    V_PASSWORD USERS.PASSWORD%TYPE;
    V_EXIST_USERNAME BOOLEAN := FALSE;
  BEGIN
    -- Force lowercase email
    NEW.EMAIL := LOWER(NEW.EMAIL);
    NEW.USERNAME := LOWER(NEW.USERNAME);
    IF NEW.USERNAME IS NOT NULL THEN
      SELECT TRUE
      INTO V_EXIST_USERNAME
      FROM USERS 
      WHERE LOWER(USERNAME) = NEW.USERNAME
      AND ID!=NEW.ID;
      IF V_EXIST_USERNAME THEN
        RAISE EXCEPTION 'cannot have two users with same username';
      END IF;
    END IF;
    
    IF TG_OP = 'UPDATE' THEN
      IF COALESCE (NEW.PASSWORD, '???') != COALESCE (OLD.PASSWORD, '???') THEN
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
$$;


ALTER FUNCTION public.users_management() OWNER TO postgres;

SET default_tablespace = '';

--
-- Name: attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attributes (
    id integer NOT NULL,
    name character varying(500)
);


ALTER TABLE public.attributes OWNER TO postgres;

--
-- Name: attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attributes_id_seq OWNER TO postgres;

--
-- Name: attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attributes_id_seq OWNED BY public.attributes.id;


--
-- Name: group_rights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_rights (
    id integer NOT NULL,
    id_group integer,
    id_right integer,
    id_impacted_group integer,
    id_impacted_user integer
);


ALTER TABLE public.group_rights OWNER TO postgres;

--
-- Name: group_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.group_rights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_rights_id_seq OWNER TO postgres;

--
-- Name: group_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.group_rights_id_seq OWNED BY public.group_rights.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    uuid character varying(255),
    name character varying(500),
    creation_date date,
    update_date timestamp without time zone,
    description character varying,
    img_url character varying(255),
    id_parentgroup integer
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.groups_id_seq OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id integer NOT NULL,
    name character varying(500),
    url_icon character varying,
    uuid character varying,
    description character varying(255)
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobs_id_seq OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: phone_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.phone_type (
    id integer NOT NULL,
    name character varying(500)
);


ALTER TABLE public.phone_type OWNER TO postgres;

--
-- Name: phone_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.phone_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.phone_type_id_seq OWNER TO postgres;

--
-- Name: phone_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.phone_type_id_seq OWNED BY public.phone_type.id;


--
-- Name: rights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rights (
    id integer NOT NULL,
    name character varying(500),
    description character varying
);


ALTER TABLE public.rights OWNER TO postgres;

--
-- Name: rights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.rights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rights_id_seq OWNER TO postgres;

--
-- Name: rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.rights_id_seq OWNED BY public.rights.id;


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_groups (
    id_user integer NOT NULL,
    id_group integer NOT NULL
);


ALTER TABLE public.user_groups OWNER TO postgres;

--
-- Name: user_phones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_phones (
    id_user integer,
    id_phonetype integer,
    value character varying(500)
);


ALTER TABLE public.user_phones OWNER TO postgres;

--
-- Name: user_rights; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_rights (
    id integer NOT NULL,
    id_user integer,
    id_right integer,
    id_impacted_group integer,
    id_impacted_user integer
);


ALTER TABLE public.user_rights OWNER TO postgres;

--
-- Name: user_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_rights_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_rights_id_seq OWNER TO postgres;

--
-- Name: user_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_rights_id_seq OWNED BY public.user_rights.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    uuid character varying(255),
    firstname character varying(50),
    lastname character varying(50),
    username character varying(50),
    password text,
    password_datelimit timestamp without time zone,
    birthdate timestamp with time zone,
    email character varying(255),
    img_url character varying(255),
    ssh_publickey text,
    id_job integer,
    creation_date date DEFAULT now(),
    update_date timestamp without time zone,
    expiration_date timestamp without time zone,
    disable_date timestamp without time zone,
    ssh_privatekey text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_pwd_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_pwd_history (
    id integer NOT NULL,
    update_date timestamp without time zone,
    id_user integer,
    password text
);


ALTER TABLE public.users_pwd_history OWNER TO postgres;

--
-- Name: users_pwd_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_pwd_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_pwd_history_id_seq OWNER TO postgres;

--
-- Name: users_pwd_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_pwd_history_id_seq OWNED BY public.users_pwd_history.id;


--
-- Name: attributes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attributes ALTER COLUMN id SET DEFAULT nextval('public.attributes_id_seq'::regclass);


--
-- Name: group_rights id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rights ALTER COLUMN id SET DEFAULT nextval('public.group_rights_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: phone_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type ALTER COLUMN id SET DEFAULT nextval('public.phone_type_id_seq'::regclass);


--
-- Name: rights id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rights ALTER COLUMN id SET DEFAULT nextval('public.rights_id_seq'::regclass);


--
-- Name: user_rights id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rights ALTER COLUMN id SET DEFAULT nextval('public.user_rights_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_pwd_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_pwd_history ALTER COLUMN id SET DEFAULT nextval('public.users_pwd_history_id_seq'::regclass);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: group_rights group_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rights
    ADD CONSTRAINT group_rights_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: groups groups_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_uuid_key UNIQUE (uuid);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_uuid_key UNIQUE (uuid);


--
-- Name: phone_type phone_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.phone_type
    ADD CONSTRAINT phone_type_pkey PRIMARY KEY (id);


--
-- Name: rights rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rights
    ADD CONSTRAINT rights_pkey PRIMARY KEY (id);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id_user, id_group);


--
-- Name: user_rights user_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rights
    ADD CONSTRAINT user_rights_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_pwd_history users_pwd_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_pwd_history
    ADD CONSTRAINT users_pwd_history_pkey PRIMARY KEY (id);


--
-- Name: users users_uuid_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_uuid_key UNIQUE (uuid);


--
-- Name: users trg_users_ins_upd; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_users_ins_upd BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE PROCEDURE public.users_management();


--
-- Name: group_rights fk_groups_right; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rights
    ADD CONSTRAINT fk_groups_right FOREIGN KEY (id_right) REFERENCES public.rights(id) ON DELETE CASCADE;


--
-- Name: user_groups fk_groups_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_groups_user FOREIGN KEY (id_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups fk_id_parentgroup; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_id_parentgroup FOREIGN KEY (id_parentgroup) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- Name: user_phones fk_id_phones_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_phones
    ADD CONSTRAINT fk_id_phones_type FOREIGN KEY (id_phonetype) REFERENCES public.phone_type(id) ON DELETE CASCADE;


--
-- Name: users_pwd_history fk_id_user_pwd_history; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_pwd_history
    ADD CONSTRAINT fk_id_user_pwd_history FOREIGN KEY (id_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_rights fk_impacted_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rights
    ADD CONSTRAINT fk_impacted_group FOREIGN KEY (id_impacted_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: group_rights fk_impacted_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rights
    ADD CONSTRAINT fk_impacted_group FOREIGN KEY (id_impacted_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_rights fk_impacted_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rights
    ADD CONSTRAINT fk_impacted_user FOREIGN KEY (id_impacted_group) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_rights fk_impacted_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rights
    ADD CONSTRAINT fk_impacted_user FOREIGN KEY (id_impacted_group) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: user_phones fk_phones_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_phones
    ADD CONSTRAINT fk_phones_user FOREIGN KEY (id_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: group_rights fk_rights_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_rights
    ADD CONSTRAINT fk_rights_group FOREIGN KEY (id_group) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: user_rights fk_rights_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rights
    ADD CONSTRAINT fk_rights_user FOREIGN KEY (id_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_groups fk_users_group; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT fk_users_group FOREIGN KEY (id_group) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: users fk_users_job; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_job FOREIGN KEY (id_job) REFERENCES public.jobs(id) ON DELETE SET NULL;


--
-- Name: user_rights fk_users_right; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rights
    ADD CONSTRAINT fk_users_right FOREIGN KEY (id_right) REFERENCES public.rights(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

