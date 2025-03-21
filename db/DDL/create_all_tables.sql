CREATE TABLE seasons (
    id serial4 NOT NULL,
    season text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp DEFAULT now() NULL,
    CONSTRAINT seasons_pkey PRIMARY KEY (id),
    CONSTRAINT seasons_season_format_check CHECK (season ~ '^\d{2}/\d{2}$'),
    CONSTRAINT seasons_dates_check CHECK (start_date < end_date)
);


CREATE TABLE clubs (
	id serial4 NOT NULL,
	"name" text NOT NULL,
	country text NOT NULL,
	city text NOT NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT clubs_pkey PRIMARY KEY (id)
);

ALTER TABLE clubs ADD COLUMN code varchar(8) UNIQUE NOT NULL DEFAULT substr(md5(random()::text), 1, 8);

CREATE TABLE associates (
	id serial4 NOT NULL,
	club_id int4 NULL,
	"name" text NOT NULL,
	"type" text NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT associates_pkey PRIMARY KEY (id),
	CONSTRAINT associates_type_check CHECK ((type = ANY (ARRAY['sponsor'::text, 'donor'::text]))),
	CONSTRAINT associates_club_id_fkey FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE
);


CREATE TABLE staff (
	id serial4 NOT NULL,
	club_id int4 NULL,
	user_id int4 NULL,
	"role" text NOT NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT staff_pkey PRIMARY KEY (id),
	CONSTRAINT staff_club_id_fkey FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE
);


CREATE TABLE teams (
	id serial4 NOT NULL,
	"name" varchar(10) NOT NULL,
	club_id int4 NOT NULL,
	CONSTRAINT teams_unique_name_per_club UNIQUE (name, club_id);
	CONSTRAINT teams_pkey PRIMARY KEY (id),
	CONSTRAINT teams_club_id_fkey FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE
);

CREATE TABLE trainings (
    id serial4 NOT NULL,
    team_id int4 NOT NULL, -- Added to reference the team
    title text NOT NULL,
    description text NULL,
    start_datetime timestamp NOT NULL, -- Start time of the training
    end_datetime timestamp NOT NULL,   -- End time of the training
    created_at timestamp DEFAULT now() NULL,
    CONSTRAINT trainings_pkey PRIMARY KEY (id),
    CONSTRAINT trainings_team_id_fkey FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
);

/*
CREATE TABLE users (
  id uuid not null references auth.users on delete cascade,
  club_id integer REFERENCES clubs(id) ON DELETE CASCADE,
  email text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  role text CHECK (role IN ('admin', 'coach', 'parent')),
  confirmed boolean DEFAULT false,
  created_at timestamp DEFAULT now()
);*/

CREATE TABLE public.profiles (
  id uuid not null PRIMARY key references auth.users on delete cascade,
  club_id integer REFERENCES clubs(id) ON DELETE CASCADE,           
  role text CHECK (role IN ('admin', 'coach', 'parent')),             
  first_name text,                                                   
  last_name text                                                     
);


alter table public.profiles enable row level security;


CREATE TABLE players (
	id serial4 NOT NULL,
	club_id int4 NULL,
	first_name text NOT NULL,
	last_name text NOT NULL,
	birth_date date NOT NULL,
	"position" text NULL,
	parent_id int4 NULL,
	created_at timestamp DEFAULT now() NULL,
	contact varchar(20) NULL,
	team_id int4 NULL,
	address text NULL,
	city varchar(100) NULL,
	nationality varchar(100) NULL,
	guardian_name text NULL,
	guardian_contact text NULL,
	CONSTRAINT players_pkey PRIMARY KEY (id),
	CONSTRAINT players_position_check CHECK (("position" = ANY (ARRAY['GK'::text, 'DF'::text, 'MF'::text, 'FW'::text]))),
	CONSTRAINT players_club_id_fkey FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE,
	CONSTRAINT players_team_id_fkey FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE SET NULL
);

CREATE TABLE training_players (
	id serial4 NOT NULL,
	training_id int4 NULL,
	player_id int4 NULL,
	status text NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT training_players_pkey PRIMARY KEY (id),
	CONSTRAINT training_players_status_check CHECK ((status = ANY (ARRAY['attended'::text, 'missed'::text, 'excused'::text]))),
	CONSTRAINT training_players_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE,
	CONSTRAINT training_players_training_id_fkey FOREIGN KEY (training_id) REFERENCES trainings(id) ON DELETE CASCADE
);

CREATE TABLE financials (
	id serial4 NOT NULL,
	club_id int4 NULL,
	player_id int4 NULL,
	"type" text NULL,
	amount numeric(10, 2) NOT NULL,
	due_date date NOT NULL,
	paid bool DEFAULT false NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT financials_pkey PRIMARY KEY (id),
	CONSTRAINT financials_type_check CHECK ((type = ANY (ARRAY['monthly_fee'::text, 'equipment'::text, 'other'::text]))),
	CONSTRAINT financials_club_id_fkey FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE,
	CONSTRAINT financials_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE player_equipment (
	id serial4 NOT NULL,
	player_id int4 NOT NULL,
	equipment_type varchar(20) NOT NULL,
	received bool DEFAULT false NOT NULL,
	received_at timestamp NULL,
	CONSTRAINT player_equipment_equipment_type_check CHECK (((equipment_type)::text = ANY ((ARRAY['1st_kit'::character varying, '2nd_kit'::character varying, 'tracksuit'::character varying, 'bag'::character varying, 'training_equipment'::character varying])::text[]))),
	CONSTRAINT player_equipment_pkey PRIMARY KEY (id),
	CONSTRAINT player_equipment_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE player_payments (
	id serial4 NOT NULL,
	player_id int4 NOT NULL,
	"month" date NOT NULL,
	amount numeric(10, 2) DEFAULT 0.00 NOT NULL,
	status varchar(10) DEFAULT 'unpaid'::character varying NOT NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT player_payments_pkey PRIMARY KEY (id),
	CONSTRAINT player_payments_status_check CHECK (((status)::text = ANY ((ARRAY['paid'::character varying, 'unpaid'::character varying])::text[]))),
	CONSTRAINT player_payments_player_id_fkey FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE TABLE transactions (
	id serial4 NOT NULL,
	club_id int4 NULL,
	user_id int4 NULL,
	financial_id int4 NULL,
	amount numeric(10, 2) NOT NULL,
	payment_date timestamp NOT NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT transactions_pkey PRIMARY KEY (id),
	CONSTRAINT transactions_club_id_fkey FOREIGN KEY (club_id) REFERENCES clubs(id) ON DELETE CASCADE,
	CONSTRAINT transactions_financial_id_fkey FOREIGN KEY (financial_id) REFERENCES financials(id) ON DELETE CASCADE
);



