--
-- PostgreSQL database cluster dump
--

-- Started on 2023-09-25 11:05:35

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
CREATE ROLE test;
ALTER ROLE test WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;
CREATE ROLE volk;
ALTER ROLE volk WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;






--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.16
-- Dumped by pg_dump version 12.16

-- Started on 2023-09-25 11:05:35

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

-- Completed on 2023-09-25 11:05:35

--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 12.16
-- Dumped by pg_dump version 12.16

-- Started on 2023-09-25 11:05:35

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
-- TOC entry 1 (class 3079 OID 16384)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 2880 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- TOC entry 214 (class 1255 OID 24650)
-- Name: appointments_inserttrigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.appointments_inserttrigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.Created_Date = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.appointments_inserttrigger() OWNER TO postgres;

--
-- TOC entry 215 (class 1255 OID 24652)
-- Name: appointments_updatetrigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.appointments_updatetrigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.Updated_Date = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.appointments_updatetrigger() OWNER TO postgres;

--
-- TOC entry 213 (class 1255 OID 16414)
-- Name: notify_messenger_messages(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_messenger_messages() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                PERFORM pg_notify('messenger_messages', NEW.queue_name::text);
                RETURN NEW;
            END;
        $$;


ALTER FUNCTION public.notify_messenger_messages() OWNER TO postgres;

--
-- TOC entry 228 (class 1255 OID 24671)
-- Name: staffcreateuserandinsert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.staffcreateuserandinsert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Проверка существования пользователя
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = NEW.Username) THEN
        -- Создание пользователя
        EXECUTE 'CREATE USER ' || NEW.Username || ' WITH PASSWORD ''' || NEW.Passwords || '''';
        
        -- Вставка записи в таблицу "Staff_Registration"
        INSERT INTO Staff_Registration (Username, Passwords, Full_Name)
        VALUES (NEW.Username, NEW.Passwords, NEW.Full_Name);
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.staffcreateuserandinsert() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 204 (class 1259 OID 24588)
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    city character varying(100),
    district character varying(100),
    geoname character varying(100),
    street character varying(100),
    house_number character varying(10),
    apartment_number character varying(10),
    postal_code character varying(10)
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 24586)
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.addresses_id_seq OWNER TO postgres;

--
-- TOC entry 2881 (class 0 OID 0)
-- Dependencies: 203
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- TOC entry 210 (class 1259 OID 24625)
-- Name: appointments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointments (
    id integer NOT NULL,
    patient_id integer,
    doctor_id integer,
    staff_registration_id integer,
    appointment_date date,
    appointment_time time without time zone,
    note text,
    created_date timestamp without time zone DEFAULT now(),
    updated_date timestamp without time zone
);


ALTER TABLE public.appointments OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 24623)
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.appointments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.appointments_id_seq OWNER TO postgres;

--
-- TOC entry 2882 (class 0 OID 0)
-- Dependencies: 209
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.appointments_id_seq OWNED BY public.appointments.id;


--
-- TOC entry 208 (class 1259 OID 24609)
-- Name: doctors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.doctors (
    id integer NOT NULL,
    fname character varying(50),
    sname character varying(50),
    lname character varying(50),
    speciality character varying(100),
    cabinet character varying(20)
);


ALTER TABLE public.doctors OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 24596)
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients (
    id integer NOT NULL,
    fname character varying(50),
    sname character varying(50),
    lname character varying(50),
    date_birth date,
    addresses_id integer,
    phone character varying(15)
);


ALTER TABLE public.patients OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 24594)
-- Name: patients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.patients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.patients_id_seq OWNER TO postgres;

--
-- TOC entry 2883 (class 0 OID 0)
-- Dependencies: 205
-- Name: patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.patients_id_seq OWNED BY public.patients.id;


--
-- TOC entry 212 (class 1259 OID 24665)
-- Name: staff_registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff_registration (
    id integer NOT NULL,
    username character varying(50),
    passwords character varying(50),
    full_name character varying(250)
);


ALTER TABLE public.staff_registration OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 24663)
-- Name: staff_registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staff_registration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staff_registration_id_seq OWNER TO postgres;

--
-- TOC entry 2884 (class 0 OID 0)
-- Dependencies: 211
-- Name: staff_registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staff_registration_id_seq OWNED BY public.staff_registration.id;


--
-- TOC entry 207 (class 1259 OID 24607)
-- Name: Врачи_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Врачи_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Врачи_id_seq" OWNER TO postgres;

--
-- TOC entry 2885 (class 0 OID 0)
-- Dependencies: 207
-- Name: Врачи_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Врачи_id_seq" OWNED BY public.doctors.id;


--
-- TOC entry 2717 (class 2604 OID 24591)
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- TOC entry 2720 (class 2604 OID 24628)
-- Name: appointments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments ALTER COLUMN id SET DEFAULT nextval('public.appointments_id_seq'::regclass);


--
-- TOC entry 2719 (class 2604 OID 24612)
-- Name: doctors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctors ALTER COLUMN id SET DEFAULT nextval('public."Врачи_id_seq"'::regclass);


--
-- TOC entry 2718 (class 2604 OID 24599)
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patients_id_seq'::regclass);


--
-- TOC entry 2722 (class 2604 OID 24668)
-- Name: staff_registration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_registration ALTER COLUMN id SET DEFAULT nextval('public.staff_registration_id_seq'::regclass);


--
-- TOC entry 2866 (class 0 OID 24588)
-- Dependencies: 204
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.addresses (id, city, district, geoname, street, house_number, apartment_number, postal_code) FROM stdin;
1	New York	Manhattan	Some Geoname	123 Main Street	1A	Apt 101	10001
2	Los Angeles	Downtown	Another Geoname	456 Elm Street	2B	Apt 202	90001
3	Chicago	North Side	Yet Another Geoname	789 Oak Street	3C	Apt 303	60601
\.


--
-- TOC entry 2872 (class 0 OID 24625)
-- Dependencies: 210
-- Data for Name: appointments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.appointments (id, patient_id, doctor_id, staff_registration_id, appointment_date, appointment_time, note, created_date, updated_date) FROM stdin;
\.


--
-- TOC entry 2870 (class 0 OID 24609)
-- Dependencies: 208
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.doctors (id, fname, sname, lname, speciality, cabinet) FROM stdin;
\.


--
-- TOC entry 2868 (class 0 OID 24596)
-- Dependencies: 206
-- Data for Name: patients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.patients (id, fname, sname, lname, date_birth, addresses_id, phone) FROM stdin;
\.


--
-- TOC entry 2874 (class 0 OID 24665)
-- Dependencies: 212
-- Data for Name: staff_registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff_registration (id, username, passwords, full_name) FROM stdin;
6	test	test	Full Name
7	test	test	Full Name
8	volk	volk	Full Name
9	volk	volk	Full Name
\.


--
-- TOC entry 2886 (class 0 OID 0)
-- Dependencies: 203
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.addresses_id_seq', 3, true);


--
-- TOC entry 2887 (class 0 OID 0)
-- Dependencies: 209
-- Name: appointments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.appointments_id_seq', 1, false);


--
-- TOC entry 2888 (class 0 OID 0)
-- Dependencies: 205
-- Name: patients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.patients_id_seq', 1, false);


--
-- TOC entry 2889 (class 0 OID 0)
-- Dependencies: 211
-- Name: staff_registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.staff_registration_id_seq', 9, true);


--
-- TOC entry 2890 (class 0 OID 0)
-- Dependencies: 207
-- Name: Врачи_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Врачи_id_seq"', 1, false);


--
-- TOC entry 2724 (class 2606 OID 24593)
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- TOC entry 2730 (class 2606 OID 24634)
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- TOC entry 2726 (class 2606 OID 24601)
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- TOC entry 2732 (class 2606 OID 24670)
-- Name: staff_registration staff_registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_registration
    ADD CONSTRAINT staff_registration_pkey PRIMARY KEY (id);


--
-- TOC entry 2728 (class 2606 OID 24614)
-- Name: doctors Врачи_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.doctors
    ADD CONSTRAINT "Врачи_pkey" PRIMARY KEY (id);


--
-- TOC entry 2736 (class 2620 OID 24651)
-- Name: appointments appointments_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER appointments_insert BEFORE INSERT ON public.appointments FOR EACH ROW EXECUTE FUNCTION public.appointments_inserttrigger();


--
-- TOC entry 2737 (class 2620 OID 24653)
-- Name: appointments appointments_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER appointments_update BEFORE UPDATE ON public.appointments FOR EACH ROW EXECUTE FUNCTION public.appointments_updatetrigger();


--
-- TOC entry 2738 (class 2620 OID 24672)
-- Name: staff_registration createuserandinserttrigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER createuserandinserttrigger AFTER INSERT ON public.staff_registration FOR EACH ROW EXECUTE FUNCTION public.staffcreateuserandinsert();


--
-- TOC entry 2735 (class 2606 OID 24640)
-- Name: appointments appointments_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.doctors(id);


--
-- TOC entry 2734 (class 2606 OID 24635)
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- TOC entry 2733 (class 2606 OID 24602)
-- Name: patients patients_addresses_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_addresses_id_fkey FOREIGN KEY (addresses_id) REFERENCES public.addresses(id);


-- Completed on 2023-09-25 11:05:36

--
-- PostgreSQL database dump complete
--

-- Completed on 2023-09-25 11:05:36

--
-- PostgreSQL database cluster dump complete
--

