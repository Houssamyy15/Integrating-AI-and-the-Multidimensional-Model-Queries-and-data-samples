--
-- PostgreSQL database dump
--

\restrict Zj0UsJL5LPGBvmSNOBF6DH2FaxeQ02FbunLzf1uue3hSNOXOjKAPtjeNC0DzIFh

-- Dumped from database version 17.10 (Ubuntu 17.10-1.pgdg22.04+1)
-- Dumped by pg_dump version 17.10

-- Started on 2026-06-12 21:29:01

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 290 (class 1259 OID 21274)
-- Name: dish; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dish (
    dish_id integer NOT NULL,
    dish_picture bytea,
    dish_name text,
    dish_picture_embedded public.vector(768)
);


ALTER TABLE public.dish OWNER TO postgres;

--
-- TOC entry 291 (class 1259 OID 21281)
-- Name: location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location (
    restaurant_id integer NOT NULL,
    restaurant_description text,
    restaurant_picture bytea,
    restaurant_picture_embedded public.vector(768),
    city text,
    country text,
    restaurant_description_embedded public.vector(1024)
);


ALTER TABLE public.location OWNER TO postgres;

--
-- TOC entry 293 (class 1259 OID 21302)
-- Name: order_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_line (
    order_id integer NOT NULL,
    date_id integer,
    dish_id integer,
    restaurant_id integer,
    unit_price double precision,
    quantity integer,
    amount integer,
    dish_picture bytea,
    review text,
    review_embedded public.vector(1024),
    dish_picture_embedded public.vector(768)
);


ALTER TABLE public.order_line OWNER TO postgres;

--
-- TOC entry 292 (class 1259 OID 21295)
-- Name: time; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."time" (
    date_id integer NOT NULL,
    month text NOT NULL,
    year integer NOT NULL
);


ALTER TABLE public."time" OWNER TO postgres;

--
-- TOC entry 5429 (class 2606 OID 21280)
-- Name: dish dish_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dish
    ADD CONSTRAINT dish_pkey PRIMARY KEY (dish_id);


--
-- TOC entry 5431 (class 2606 OID 21287)
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (restaurant_id);


--
-- TOC entry 5435 (class 2606 OID 21308)
-- Name: order_line order_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT order_line_pkey PRIMARY KEY (order_id);


--
-- TOC entry 5433 (class 2606 OID 21301)
-- Name: time time_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."time"
    ADD CONSTRAINT time_pkey PRIMARY KEY (date_id);


--
-- TOC entry 5436 (class 2606 OID 21309)
-- Name: order_line order_line_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT order_line_date_id_fkey FOREIGN KEY (date_id) REFERENCES public."time"(date_id);


--
-- TOC entry 5437 (class 2606 OID 21314)
-- Name: order_line order_line_dish_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT order_line_dish_id_fkey FOREIGN KEY (dish_id) REFERENCES public.dish(dish_id);


--
-- TOC entry 5438 (class 2606 OID 21319)
-- Name: order_line order_line_restaurant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line
    ADD CONSTRAINT order_line_restaurant_id_fkey FOREIGN KEY (restaurant_id) REFERENCES public.location(restaurant_id);


-- Completed on 2026-06-12 21:29:02

--
-- PostgreSQL database dump complete
--

\unrestrict Zj0UsJL5LPGBvmSNOBF6DH2FaxeQ02FbunLzf1uue3hSNOXOjKAPtjeNC0DzIFh

