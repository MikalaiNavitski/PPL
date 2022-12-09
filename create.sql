DROP SCHEMA IF EXISTS ppl CASCADE;
CREATE SCHEMA IF NOT EXISTS ppl;

CREATE TYPE ppl.weekDay AS ENUM ('MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN');

CREATE CAST (varchar AS ppl.weekDay) WITH INOUT AS IMPLICIT;

CREATE TYPE ppl.SendingType AS ENUM ('Place', 'Storage', 'Parcel_locker', 'Courier');

CREATE CAST (varchar AS ppl.SendingType) WITH INOUT AS IMPLICIT;

CREATE TYPE ppl.weightType AS ENUM ('Small', 'Normal', 'Huge');

CREATE CAST (varchar AS ppl.weightType) WITH INOUT AS IMPLICIT;

CREATE TYPE ppl.speedType AS ENUM ('Normal', 'Special');

CREATE CAST (varchar AS ppl.speedType) WITH INOUT AS IMPLICIT;

CREATE SEQUENCE ppl.status_id START 1 increment by 1 ;

CREATE SEQUENCE ppl.sending_id START 1 increment by 1 ;

CREATE SEQUENCE ppl.parcel_id START 1 increment by 1 ;

CREATE SEQUENCE ppl.address_id START 1 increment by 1  ;

CREATE SEQUENCE ppl.user_id START 1 increment by 1  ;


CREATE  TABLE ppl.cells ( 
	id                   serial  NOT NULL  ,
	parcel_locker_id     serial  NOT NULL  ,
	height               integer  NOT NULL  ,
	"length"             integer  NOT NULL  ,
	width                integer  NOT NULL  ,
	CONSTRAINT pk_cells PRIMARY KEY ( id )
 );

CREATE  TABLE ppl.couriers ( 
	id                   serial  NOT NULL  ,
	firstname            varchar(64)  NOT NULL  ,
	lastname             varchar(64)  NOT NULL  ,
	phone_number         numeric(9)  NOT NULL  ,
	email                varchar(64)  NOT NULL  ,
	hour_salary          double precision    ,
	CONSTRAINT pk_couriers PRIMARY KEY ( id )
 );


CREATE  TABLE ppl.couriers_schedule ( 
	id_courier           serial  NOT NULL  ,
	"day"                ppl.weekDay  NOT NULL  ,
	"from"               integer default 10  NOT NULL  ,
	"until"              integer default 18 NOT NULL  ,
	constraint time_check check("from" < "until"),
	CONSTRAINT pk_couriers_schedule PRIMARY KEY ( id_courier, "day" )
 );

CREATE  TABLE ppl.couriers_trucks ( 
	id                   serial  NOT NULL  ,
	truck_number         char(8)  NOT NULL  ,
	max_weight           integer  NOT NULL  ,
	height               integer  NOT NULL  ,
	"length"             integer  NOT NULL  ,
	width                integer  NOT NULL  ,
	CONSTRAINT pk_couriers_transport PRIMARY KEY ( id )
 );

CREATE  TABLE ppl.parcel_history ( 
	time                 timestamp  NOT NULL  ,
	parcel_id            serial  NOT NULL  ,
	status_id            serial  NOT NULL  ,
	status_info_id       integer,
	CONSTRAINT pk_parcel_history PRIMARY KEY ( time, parcel_id ),
	CONSTRAINT sii_unq UNIQUE(status_info_id)
 );

CREATE  TABLE ppl.parcel_lockers ( 
	id                   serial  NOT NULL  ,
	name                 char(6)  NOT NULL  ,
	city                 varchar(30)  NOT NULL  ,
	street               varchar(40)  NOT NULL  ,
	house_number         integer  NOT NULL  ,
	postal_code          numeric(5)  NOT NULL  ,
	is_active            boolean  NOT NULL  ,
	CONSTRAINT pk_packomaty PRIMARY KEY ( id ),
	CONSTRAINT unq_parcel_lockers_name UNIQUE ( name ) 
 );

CREATE  TABLE ppl.parcels ( 
	id                   integer  NOT NULL  ,
	weight               integer   NOT NULL,
	height               integer   NOT NULL ,
	"length"             integer   NOT NULL ,
	width                integer   NOT NULL ,
	sender_id            serial  NOT NULL  ,
	sender_address       serial  NOT NULL  ,
	sending_type         ppl.SendingType  NOT NULL  ,
	receiver_id           serial  NOT NULL  ,
	receiver_address      serial  NOT NULL  ,
	receiving_type       ppl.SendingType  NOT NULL  ,
	parcel_speed          ppl.speedType default 'Normal',
	CONSTRAINT pk_parcels PRIMARY KEY ( id ),
	CONSTRAINT sr_check CHECK(sending_type != 'Storage' and receiving_type != 'Storage'),
	CONSTRAINT weight_check CHECK(weight <= 20000),
	CONSTRAINT length_check CHECK("length" <= 1000),
	CONSTRAINT width_check CHECK(width <= 1000),
	CONSTRAINT height_check CHECK(height <= 1000)
 );

CREATE  TABLE ppl.places ( 
	id                   serial  NOT NULL  ,
	name                 char(6)  NOT NULL  ,
	city                 varchar(30)  NOT NULL  ,
	street               varchar(40)  NOT NULL  ,
	house_number         integer  NOT NULL  ,
	postal_code          numeric(5)  NOT NULL  ,
	CONSTRAINT pk_places PRIMARY KEY ( id ),
	CONSTRAINT unq_places_name UNIQUE ( name ) 
 );

CREATE TABLE ppl.couriers_statuses(
	courier_id           serial NOT NULL,
	"from"               timestamp NOT NULL,
	"to"                 timestamp,
	CONSTRAINT time_check CHECK ("from" < "to" or "to" is null)
);

CREATE  TABLE ppl.places_schedule ( 
	id_place             serial references ppl.places(id)  NOT NULL  ,
	"day"                ppl.weekDay  NOT NULL  ,
	"from"               integer  NOT NULL  ,
	"until"              integer  NOT NULL  ,
	CONSTRAINT time_chec CHECK("from" < "until"),
	CONSTRAINT pk_places_schedule PRIMARY KEY ( id_place, "day" )
 );

CREATE  TABLE ppl.status_info_given ( 
	id                   integer default nextval('ppl.status_id')  NOT NULL  ,
	type_to 			 ppl.SendingType NOT NULL,
	to_whom              integer  NOT NULL  ,
	CONSTRAINT pk_status_given_info PRIMARY KEY ( id ),
	CONSTRAINT pk_type_to_check CHECK(type_to != 'Storage')
 );

CREATE  TABLE ppl.status_info_registered ( 
	id                   integer default nextval('ppl.status_id')  NOT NULL  ,
	id_place             integer    ,
	CONSTRAINT pk_status_regestrated_info PRIMARY KEY ( id )
 );

CREATE  TABLE ppl.status_info_storage ( 
	id                   integer default nextval('ppl.status_id')  NOT NULL  ,
	type_storage         ppl.SendingType NOT NULL ,
	storage_id           integer  NOT NULL  ,
	CONSTRAINT pk_status_storage_info PRIMARY KEY ( id ),
	CONSTRAINT pk_type_storage_check CHECK(type_storage != 'Courier')
 );

CREATE  TABLE ppl.status_info_transit ( 
	id                   integer default nextval('ppl.status_id')  NOT NULL  ,
	courier_id           integer  NOT NULL  ,
	truck_id             serial  NOT NULL  ,
	type_from            ppl.SendingType  NOT NULL  ,
	id_from              integer    ,
	type_where           ppl.SendingType  NOT NULL  ,
	id_to                integer   ,
	CONSTRAINT pk_status_transit_info PRIMARY KEY ( id ),
	CONSTRAINT pk_type_from_check CHECK(type_from != 'Courier'),
	CONSTRAINT pk_type_where_check CHECK(type_where != 'Courier')
 );

CREATE  TABLE ppl.statuses ( 
	id                   serial  NOT NULL  ,
	name                 varchar(100)  NOT NULL  ,
	info_table_name      varchar(100)  NOT NULL  ,
	short_name           varchar(100)  GENERATED ALWAYS AS (left(name, 3)) STORED,
    CONSTRAINT name_check CHECK (name = 'REGISTERED' or name = 'GIVEN' or name = 'TRANSIT' or name = 'STORAGE' or name = 'DELIVERED'),
	CONSTRAINT pk_statuses PRIMARY KEY ( id )
 );

CREATE  TABLE ppl.storages ( 
	id                   serial  NOT NULL  ,
	city                 varchar(30)  NOT NULL  ,
	street               varchar(40)  NOT NULL  ,
	house_number         integer  NOT NULL  ,
	postal_code          numeric(5)  NOT NULL  ,
	volume               bigint  NOT NULL  ,
	CONSTRAINT pk_places_0 PRIMARY KEY ( id )
 );

CREATE  TABLE ppl.user_addresses ( 
	id                   integer NOT NULL  ,
	user_id              serial  NOT NULL  ,
	city                 varchar(30)  NOT NULL  ,
	street               varchar(40)  NOT NULL  ,
	house_number          integer  NOT NULL  ,
	flat_number          integer    ,
	postal_code          numeric(5)  NOT NULL  ,
	CONSTRAINT pk_user_addresses PRIMARY KEY ( id )
 );

CREATE  TABLE ppl.users ( 
	id                   integer  NOT NULL  ,
	firstname            varchar(64)  NOT NULL  ,
	lastname             varchar(64)  NOT NULL  ,
	login                varchar(64),
	password_hash        integer,
	phone_number         numeric(9) NOT NULL,
	email                varchar(64) NOT NULL,
	CONSTRAINT pk_users PRIMARY KEY ( id ),
	CONSTRAINT unq_login UNIQUE ( login ),
	CONSTRAINT unq_em_check UNIQUE(email),
	CONSTRAINT unq_pho_check UNIQUE(phone_number),
	CONSTRAINT proper_email CHECK (email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
 );




ALTER TABLE ppl.cells ADD FOREIGN KEY (parcel_locker_id) REFERENCES ppl.parcel_lockers(id);
ALTER TABLE ppl.parcels ADD FOREIGN KEY (sender_id) REFERENCES ppl.users(id);
ALTER TABLE ppl.parcels ADD FOREIGN KEY (sender_address) REFERENCES ppl.user_addresses(id);
ALTER TABLE ppl.parcels ADD FOREIGN KEY (receiver_id) REFERENCES ppl.users(id);
ALTER TABLE ppl.parcels ADD FOREIGN KEY (receiver_address) REFERENCES ppl.user_addresses(id);
ALTER TABLE ppl.user_addresses ADD FOREIGN KEY (user_id) REFERENCES ppl.users(id);
ALTER TABLE ppl.couriers_schedule ADD FOREIGN KEY (id_courier) REFERENCES ppl.couriers(id);
ALTER TABLE ppl.parcel_history ADD FOREIGN KEY (parcel_id) REFERENCES ppl.parcels(id);
ALTER TABLE ppl.parcel_history ADD FOREIGN KEY (status_id) REFERENCES ppl.statuses(id);
ALTER TABLE ppl.status_info_registered ADD FOREIGN KEY (id_place) REFERENCES ppl.places(id);
ALTER TABLE ppl.status_info_transit ADD FOREIGN KEY (courier_id) REFERENCES ppl.couriers(id);
ALTER TABLE ppl.status_info_transit ADD FOREIGN KEY (truck_id) REFERENCES ppl.couriers_trucks(id);
ALTER TABLE ppl.couriers_statuses ADD FOREIGN KEY (courier_id) REFERENCES ppl.couriers(id);
ALTER TABLE ppl.status_info_registered ADD FOREIGN KEY(id_place) REFERENCES ppl.places(id);

INSERT INTO ppl.statuses( id, name, info_table_name ) VALUES ( 0, 'REGISTERED', 'status_info_registered');
INSERT INTO ppl.statuses( id, name, info_table_name ) VALUES ( 4, 'DELIVERED', 'status_info_delivered');
INSERT INTO ppl.statuses( id, name, info_table_name ) VALUES ( 2, 'TRANSIT', 'status_info_transit');
INSERT INTO ppl.statuses( id, name, info_table_name ) VALUES ( 1, 'GIVEN', 'status_info_given');
INSERT INTO ppl.statuses( id, name, info_table_name ) VALUES ( 3, 'STORAGE', 'status_info_storage');

create or replace function ppl.parcelCurrentStatus(idp int)
    returns integer as
$$
declare
begin
	return (SELECT status_info_id from ppl.parcel_history where parcel_id = idp and "time" = (SELECT max(time) from ppl.parcel_history where parcel_id = idp GROUP BY parcel_id)); 
end;
$$
language plpgsql;

create or replace function ppl.parcelFromStatus(ids int)
    returns integer as
$$
declare
begin
	return (SELECT parcel_id from ppl.parcel_history where status_info_id = ids);
end;
$$
language plpgsql;

create or replace function ppl.pc_add()
    returns trigger as
$pc_add$
declare
	cur ppl.parcel_history%rowtype;
	save ppl.parcel_history%rowtype;
begin
	
	if (select short_name from ppl.statuses where id = new.status_id) = 'REG' then
		if(select count(*) from ppl.status_info_registered where id = new.status_info_id) = 0 then
			RAISE EXCEPTION 'This status does not exists';
		end if;
	end if;

	if (select short_name from ppl.statuses where id = new.status_id) = 'GIV' then
		if(select count(*) from ppl.status_info_given where id = new.status_info_id) = 0 then
			RAISE EXCEPTION 'This status does not exists';
		end if;
		if(select sending_type from ppl.parcels where id = new.parcel_id) != (select type_to from ppl.status_info_given where id = new.status_info_id) then
			RAISE EXCEPTION 'Not correct type';
		end if;
	end if;

	if (select short_name from ppl.statuses where id = new.status_id) = 'DEL' then
		for cur in (select * from ppl.parcel_history where parcel_id = new.parcel_id ORDER BY time)
		loop
			if cur.status_id != 4 then
				save = cur;
			end if; 
		end loop;
		
		if(select receiving_type from ppl.parcels where id = new.parcel_id) = 'Courier' then
			if save.status_id != 1 then
				RAISE EXCEPTION 'Not correct type';
			end if;		
		end if; 
 		
		if(select receiving_type from ppl.parcels where id = new.parcel_id) != 'Courier' then
			if save.status_id != 3 or (select type_storage from ppl.status_info_storage where id = save.status_info_id) != (select receiving_type from ppl.parcels where id = new.parcel_id)  then
				RAISE EXCEPTION 'Not correct type';
			end if;
		end if;	

		if new.status_info_id is not null then
			RAISE EXCEPTION 'This type of status doesn`t point to another table, "status_info_id" must be null';
		end if;
	end if;

	if (select short_name from ppl.statuses where id = new.status_id) = 'TRA' then
		if(select count(*) from ppl.status_info_transit where id = new.status_info_id) = 0 then
			RAISE EXCEPTION 'This status does not exists';
		end if;
	end if;
	
	if (select short_name from ppl.statuses where id = new.status_id) = 'STO' then
		if(select count(*) from ppl.status_info_storage where id = new.status_info_id) = 0 then
			RAISE EXCEPTION 'This status does not exists';
		end if;
	end if;
	
	return new;
end;
$pc_add$
language plpgsql;

CREATE CONSTRAINT TRIGGER pc_add after INSERT on ppl.parcel_history
DEFERRABLE INITIALLY DEFERRED FOR each row execute procedure ppl.pc_add();


create or replace function ppl.pc_add_at_time()
    returns trigger as
$pc_add$
declare
	t1 int;
	t2 int;
begin
	
	if(select count(*) from ppl.parcel_history where parcel_id = new.parcel_id) = 0 then
		if new.status_id != 0 then
			RAISE EXCEPTION 'Wrong order';
		end if;
		return new;
	end if;
	
	if (select max(time) from ppl.parcel_history where parcel_id = new.parcel_id) > new.time then
		RAISE EXCEPTION 'You can`t go past';
	end if;

	t1 = (select status_id from ppl.parcel_history where parcel_id = new.parcel_id and time = (select max(time) from ppl.parcel_history where parcel_id = new.parcel_id));

	t2 = new.status_id;

	if( (t1 = 0 and t2 = 1) or (t1 = 1 and t2 = 3) or (t1 = 1 and t2 = 4) or (t1 = 2 and t2 = 3) or (t1 = 3 and t2 = 2) or (t1 = 3 and t2 = 4)) then
		return new;
	else
		RAISE EXCEPTION 'Wrong order';
	end if;

	return new;
end;
$pc_add$
language plpgsql;


CREATE TRIGGER pc_add_at_time before INSERT on ppl.parcel_history
FOR each row execute procedure ppl.pc_add_at_time();


create or replace function ppl.cour_st_upd()
    returns trigger as
$cour_st_upd$
declare
begin
    if new.courier_id != old.courier_id or new."from" != old."from" or (old."to" is not null and old."to" != new."to") then
		RAISE EXCEPTION 'You can`t change this information';
	end if;
	return new;
end;
$cour_st_upd$
language plpgsql;

CREATE TRIGGER cour_st_upd before UPDATE on ppl.couriers_statuses
FOR each row execute procedure ppl.cour_st_upd();

create or replace function ppl.cour_st_add()
    returns trigger as
$cour_st_add$
declare
begin
    if (select count(*) from ppl.couriers_statuses where courier_id = new.courier_id) = 0 then
		return new;
	end if;
	if (select "to" from ppl.couriers_statuses where courier_id = new.courier_id and "from" = (select max("from") from ppl.couriers_statuses where courier_id = new.courier_id group by courier_id)) is null then
		RAISE EXCEPTION 'This courier is still working at this moment';
	end if;
	if (select "to" from ppl.couriers_statuses where courier_id = new.courier_id and "from" = (select max("from") from ppl.couriers_statuses where courier_id = new.courier_id group by courier_id)) >= new."from" then
		RAISE EXCEPTION 'This courier is still working at this moment';
	end if;
	return new;
end;
$cour_st_add$
language plpgsql;

CREATE TRIGGER cour_st_add before INSERT on ppl.couriers_statuses
FOR each row execute procedure ppl.cour_st_add();

create or replace function ppl.is_courier_working(idg int)
    returns boolean as
$$
declare
begin
    if (select count(*) from ppl.couriers_statuses where courier_id = idg) = 0 then
		return false;
	end if;
	if (select "to" from ppl.couriers_statuses where courier_id = idg and "from" = (select max("from") from ppl.couriers_statuses where courier_id = idg group by courier_id)) is null then
		return true;
	else
		return false;
	end if;
end;
$$
language plpgsql;

create view ppl.who_works as (select * from ppl.couriers where is_courier_working(id) = true); 

create or replace function ppl.user_add()
    returns trigger as
$user_add$
declare
begin
	if new.login is null then
		if (select count(*) from ppl.users where email = new.email or phone_number = new.phone_number) > 0 then
			RAISE EXCEPTION 'This user already exists';
		end if;
		new.password_hash = null;
	else	
		if  new.password_hash is null then
			RAISE EXCEPTION 'You must have password';
		end if;
		if (select count(*) from ppl.users where (email = new.email or phone_number = new.phone_number) and login is not null)  > 0 then
			RAISE EXCEPTION 'This user already exists';
		end if;
		if (select count(*) from ppl.users where (email = new.email or phone_number = new.phone_number))  > 0 then
			if (select count(*) from ppl.users (email = new.email and phone_number != new.phone_number)) + (select count(*) from ppl.users (email != new.email and phone_number = new.phone_number)) >= 2 then
				RAISE EXCEPTION 'There are two users that have the same email or phone';
			end if;
			RAISE NOTICE 'This user was pseudo';
			UPDATE ppl.users SET firstname = new.firstname, lastname = new.lastname, login = new.login, password_hash = new.password_hash, phone_number = new.phone_number, email = new.email where (email = new.email or phone_number = new.phone_number);
			return null;
		end if;
	end if;
	new.id = nextval('ppl.user_id');
	return new;
end;
$user_add$
language plpgsql;

CREATE TRIGGER user_add before INSERT on ppl.users
FOR each row execute procedure ppl.user_add();

create or replace function ppl.user_upd()
    returns trigger as
$user_upd$
declare
begin
	if new.id != old.id then
		RAISE EXCEPTION 'You can`t change this information';
	end if;
	return new;
end;
$user_upd$
language plpgsql;

CREATE TRIGGER user_upd before UPDATE on ppl.users
FOR each row execute procedure ppl.user_upd();



create or replace function ppl.type_calc(weight int)
    returns ppl.weightType as
$$
declare
begin
	if weight < 3000 then
		return 'Small';
	end if;
	if weight < 15000 then
		return 'Normal';
	end if;
	return 'Huge';
end;
$$
language plpgsql;

create or replace function ppl.price_calc(volume int, siz ppl.weightType, speed ppl.speedType)
    returns numeric as
$$
declare
	ans numeric;
begin
	ans := 0.001 * volume;
	if siz = 'Small' then
		ans := ans * 0.8;
	end if;

	if siz = 'Huge' then
		ans := ans * 2;
	end if;

	if speed = 'Special' then
		ans := ans * 2;
	end if;
	if  ans < 1 then
		ans := 1;
	end if;
	return ans;
end;
$$
language plpgsql;

--INSERT INTO ppl.parcels(weight, height, length, width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed)
  --values(12000, 100, 23, 55, 1 , 4,'a', 3, 0,'a', 'Special');

--select * from ppl.parcels;

CREATE or replace RULE places_add AS ON INSERT TO ppl.places
DO also (UPDATE ppl.places set id = nextval('ppl.sending_id') where id = new.id);

CREATE or replace RULE storage_add AS ON INSERT TO ppl.storages
DO also (UPDATE ppl.storages set id = nextval('ppl.sending_id') where id = new.id);

CREATE or replace RULE couriers_add AS ON INSERT TO ppl.couriers
DO also (UPDATE ppl.couriers set id = nextval('ppl.sending_id') where id = new.id);

CREATE or replace RULE cells_add AS ON INSERT TO ppl.cells
DO also (UPDATE ppl.cells set id = nextval('ppl.sending_id') where id = new.id);


create or replace function ppl.is_cell_empty(idg int)
    returns boolean as
$$
declare
	cur ppl.status_info_given%rowtype;
	cur2 ppl.status_info_storage%rowtype;
begin
    if (select count(*) from ppl.status_info_given where to_whom = idg) = 0 and (select count(*) from ppl.status_info_storage pr where pr.storage_id = idg) = 0 then
		return true;
	end if;
	
	if (select count(*) from ppl.status_info_storage pr where pr.storage_id = idg) != 0 then
		for cur2 in (select * from ppl.status_info_storage pr where pr.storage_id = idg)
		LOOP	
			if ppl.parcelCurrentStatus(ppl.parcelFromStatus(cur2.id)) = cur2.id then
				return false;
			end if;
		end loop;
	end if;
	return true;
end;
$$
language plpgsql;

--select status_id from ppl.parcel_history where parcel_id = ppl.parcelFromStatus(1) and time = (select max(time) from ppl.parcel_history where status_info_id != 1 and parcel_id =ppl.parcelFromStatus(1));

create or replace function ppl.sis_add()
    returns trigger as
$sis_add$
declare
begin
	if new.type_storage = 'Parcel_locker' then
		if (select count(*) from ppl.cells where id = new.storage_id) = 0 then
			RAISE EXCEPTION 'This cell doesn`t exists';
		end if;
		if (select ppl.is_cell_empty(new.storage_id)) = false then
			RAISE EXCEPTION 'This cell isn`t empty';
		end if;
		return new;
	end if;

	if new.type_storage = 'Storage' then
		if (select count(*) from ppl.storages where id = new.storage_id) = 0 then
			RAISE EXCEPTION 'This storage doesn`t exists';
		end if;
		return new;
	end if;

	if new.type_storage = 'Place' then
		if (select count(*) from ppl.places where id = new.storage_id) = 0 then
			RAISE EXCEPTION 'This place doesn`t exists';
		end if;
		return new;
	end if;

	return new;
end;
$sis_add$
language plpgsql;

CREATE TRIGGER sis_add before INSERT on ppl.status_info_storage
FOR each row execute procedure ppl.sis_add();


create or replace function ppl.par_add()
    returns trigger as
$par_add$
declare
begin
	new.id = nextval('ppl.parcel_id');
	return new;
end;
$par_add$
language plpgsql;

CREATE TRIGGER par_add before INSERT on ppl.parcels
FOR each row execute procedure ppl.par_add();


create or replace function ppl.us_ad_add()
    returns trigger as
$us_ad_add$
declare
begin
	new.id = nextval('ppl.address_id');
	return new;
end;
$us_ad_add$
language plpgsql;

CREATE TRIGGER us_ad_add before INSERT on ppl.user_addresses
FOR each row execute procedure ppl.us_ad_add();


create or replace function ppl.sig_add()
    returns trigger as
$sig_add$
declare
begin

	if new.type_to = 'Parcel_locker' then
		if (select count(*) from ppl.cells where id = new.to_whom) = 0 then
			RAISE EXCEPTION 'This cell doesn`t exists';
		end if;
		if (select ppl.is_cell_empty(new.to_whom)) = false then
			RAISE EXCEPTION 'This cell isn`t empty';
		end if;
		if (select height from ppl.cells where id = new.to_whom) < (select height from ppl.parcels where id = ppl.parcelFromStatus(new.id)) then
			RAISE EXCEPTION 'The cell has too small height';
		end if;
		if (select width from ppl.cells where id = new.to_whom) < (select width from ppl.parcels where id = ppl.parcelFromStatus(new.id)) then
			RAISE EXCEPTION 'The cell has too small width';
		end if;
		if (select length from ppl.cells where id = new.to_whom) < (select length from ppl.parcels where id = ppl.parcelFromStatus(new.id)) then
			RAISE EXCEPTION 'The cell has too small length';
		end if;
	
		return new;
	end if;

	if new.type_TO = 'Place' then
		if (select count(*) from ppl.places where id = new.to_whom) = 0 then
			RAISE EXCEPTION 'This place doesn`t exists';
		end if;
		return new;
	end if;

	if new.type_to = 'Courier' then
		if (select count(*) from ppl.couriers where id = new.to_whom) = 0 then
			RAISE EXCEPTION 'This courier doesn`t exists';
		end if;
		if (select count(*) from ppl.who_works where id = new.to_whom) = 0 then
			RAISE EXCEPTION 'This courier no longer working';
		end if;
		return new;
	end if;
	return new;
end;
$sig_add$
language plpgsql;


CREATE TRIGGER sig_add before INSERT on ppl.status_info_given
FOR each row execute procedure ppl.sig_add();

create or replace function ppl.sit_add()
    returns trigger as
$sit_add$
declare
	cur ppl.status_info_transit%rowtype;
begin
	for cur in (select * from ppl.status_info_transit)
	loop
		if cur.truck_id = new.truck_id and cur.courier_id != new.courier_id then
			if ppl.parcelCurrentStatus(ppl.parcelFromStatus(cur.id)) = cur.id then
				RAISE EXCEPTION 'This truck already have taken by another courier';
			end if;
		end if;
		if cur.truck_id != new.truck_id and cur.courier_id = new.courier_id then
			if ppl.parcelCurrentStatus(ppl.parcelFromStatus(cur.id)) = cur.id then
				RAISE EXCEPTION 'This courier uses another truck at this moment';
			end if;
		end if;
	end loop;

	if new.type_from = 'Place' then
		if (select count(*) from ppl.places where id = new.id_from) = 0 then
			RAISE EXCEPTION 'The place from what you deliver, doesn`t exists';
		end if;
	end if;

	if new.type_from = 'Storage' then
		if (select count(*) from ppl.storages where id = new.id_from) = 0 then
			RAISE EXCEPTION 'The storage from what you deliver, doesn`t exists';
		end if;
	end if;

	if new.type_from = 'Parcel_locker' then
		if (select count(*) from ppl.cells where id = new.id_from) = 0 then
			RAISE EXCEPTION 'The cell from what you deliver, doesn`t exists';
		end if;
	end if;
		
		if new.type_where = 'Place' then
		if (select count(*) from ppl.places where id = new.id_to) = 0 then
			RAISE EXCEPTION 'The place where you deliver, doesn`t exists';
		end if;
	end if;

	if new.type_where = 'Storage' then
		if (select count(*) from ppl.storages where id = new.id_to) = 0 then
			RAISE EXCEPTION 'The storage where you deliver, doesn`t exists';
		end if;
	end if;

	if new.type_where = 'Parcel_locker' then
		if (select count(*) from ppl.cells where id = new.id_to) = 0 then
			RAISE EXCEPTION 'The cell where you deliver, doesn`t exists';
		end if;
		if (select ppl.is_cell_empty(new.id_to)) = false then
			RAISE EXCEPTION 'The cell where you deliver isn`t empty';
		end if;
		if (select height from ppl.cells where id = new.id_to) < (select height from ppl.parcels where id = ppl.parcelFromStatus(new.id)) then
			RAISE EXCEPTION 'The cell has too small height';
		end if;
		if (select width from ppl.cells where id = new.id_to) < (select width from ppl.parcels where id = ppl.parcelFromStatus(new.id)) then
			RAISE EXCEPTION 'The cell has too small width';
		end if;
		if (select length from ppl.cells where id = new.id_to) < (select length from ppl.parcels where id = ppl.parcelFromStatus(new.id)) then
			RAISE EXCEPTION 'The cell has too small length';
		end if;
	end if;
	return new;
end;
$sit_add$
language plpgsql;

CREATE TRIGGER sit_add before INSERT on ppl.status_info_transit
FOR each row execute procedure ppl.sit_add();

create view ppl.user_statistiсs as (SELECT us.firstname, us.lastname, us.login, COALESCE((select count(par.id) from ppl.parcels par where par.sender_id = us.id GROUP BY par.sender_id),0) as "Number of sending", 
coalesce((select count(par2.id) from ppl.parcels par2 where par2.receiver_id = us.id GROUP BY par2.receiver_id),0) as "Number of receivings" from ppl.users us);

--SELECT * FROM ppl.user_statistiсs;
--SELECT * FROM ppl.parcels;\

create or replace function ppl.status_information(idg int, ti timestamp)
	returns varchar as
$$
declare
	result varchar;
begin
	if (select status_id from ppl.parcel_history where parcel_id = idg and time = ti) = 0 then
		return 'Registered';
	end if;
	if (select status_id from ppl.parcel_history where parcel_id = idg and time = ti) = 4 then
		return 'Delivered';
	end if;
	if (select status_id from ppl.parcel_history where parcel_id = idg and time = ti) = 1 then
		result = 'Given to ';
		if ( select type_to from ppl.status_info_given where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Place' then
			result = result || 'Place ';
			result = result || (select name from ppl.places where id = ( select to_whom from ppl.status_info_given where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_to from ppl.status_info_given where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Parcel_locker' then
			result = result || 'Parcel_locker ';
			result = result || (select pc.name from ppl.cells ce JOIN ppl.parcel_lockers pc ON pc.id = ce.parcel_locker_id  where ce.id = ( select to_whom from ppl.status_info_given where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_to from ppl.status_info_given where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Courier' then
			result = result || 'Courier';
		end if; 

		return result;
	end if;

	if (select status_id from ppl.parcel_history where parcel_id = idg and time = ti) = 3 then
		result = 'Stored in ';
		if ( select type_storage from ppl.status_info_storage where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Place' then
			result = result || 'Place ';
			result = result || (select name from ppl.places where id = ( select storage_id from ppl.status_info_storage where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_storage from ppl.status_info_storage where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Parcel_locker' then
			result = result || 'Parcel_locker ';
			result = result || (select pc.name from ppl.cells ce JOIN ppl.parcel_lockers pc ON pc.id = ce.parcel_locker_id  where ce.id = ( select storage_id from ppl.status_info_storage where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_storage from ppl.status_info_storage where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Storage' then
			result = result || 'Storage ';
			result = result || (select city || ' ' || street from ppl.storages where id = ( select storage_id from ppl.status_info_storage where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		return result;
	end if;

	if (select status_id from ppl.parcel_history where parcel_id = idg and time = ti) = 2 then
		result = 'Transited from ';
		if ( select type_from from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Place' then
			result = result || 'Place ';
			result = result || (select name from ppl.places where id = ( select id_from from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_from from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Parcel_locker' then
			result = result || 'Parcel_locker ';
			result = result || (select pc.name from ppl.cells ce JOIN ppl.parcel_lockers pc ON pc.id = ce.parcel_locker_id  where ce.id = ( select id_from from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_from from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Storage' then
			result = result || 'Storage ';
			result = result || (select city || ' ' || street from ppl.storages where id = ( select id_from from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 


		result = result || ' to ';
		if ( select type_where from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Place' then
			result = result || 'Place ';
			result = result || (select name from ppl.places where id = ( select id_to from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_where from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Parcel_locker' then
			result = result || 'Parcel_locker ';
			result = result || (select pc.name from ppl.cells ce JOIN ppl.parcel_lockers pc ON pc.id = ce.parcel_locker_id  where ce.id = ( select id_to from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		if ( select type_where from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ) = 'Storage' then
			result = result || 'Storage ';
			result = result || (select city || ' ' || street from ppl.storages where id = ( select id_to from ppl.status_info_transit where id = (select status_info_id from ppl.parcel_history where parcel_id = idg and time = ti) ));
		end if; 

		return result;
	end if;

end;
$$
language plpgsql;

create or replace function ppl.all_statuses(pr int)
	returns TABLE(status_name varchar(100), "time" timestamp, information varchar) as
$$
begin
	return query (select st.name, par.time, ppl.status_information(par.parcel_id, par.time) from ppl.parcel_history par JOIN ppl.statuses st ON st.id = par.status_id where par.parcel_id = pr) ORDER BY 2;
end;
$$
language plpgsql;

create or replace function ppl.check_login(log varchar, pashash int)
	returns int as
$$
begin
	if (select count(*) from ppl.users where login = log) = 0 then
		RAISE EXCEPTION 'User with this login doesn`t exist';
	end if;
	
	if (select password_hash from ppl.users where login = log) != pashash then
		RAISE EXCEPTION 'Wrong password';
	end if;

	return (select id from ppl.users where login = log); 
end;
$$
language plpgsql;



create or replace function ppl.register(fname varchar, lname varchar, log varchar, pas_hash int, phone int, mail varchar)
	returns int as
$$
begin
	if log = null or pas_hash = null then
		RAISE EXCEPTION 'You must to have login and password';	
	end if;
	if (select count(*) from ppl.users where login = log ) > 0 then
		RAISE EXCEPTION 'User with this login already exists';
	end if;
	
	if (select count(*) from ppl.users where mail = email and login is not null) > 0 then
		RAISE EXCEPTION 'User with this email already exists';
	end if;

	if (select count(*) from ppl.users where phone = phone_number and login is not null) > 0 then
		RAISE EXCEPTION 'User with this phone already exists';
	end if;

	insert into ppl.users(firstname, lastname, login, password_hash, phone_number, email) values(fname, lname, log, pas_hash, phone, mail);

	return (select id from ppl.users where login = log); 
end;
$$
language plpgsql;

create or replace function ppl.register_pseudo(fname varchar, lname varchar, phone int, mail varchar)
	returns int as
$$
begin
	if (select count(*) from ppl.users where mail = email) > 0 then
		RAISE EXCEPTION 'User with this email already exists';
	end if;

	if (select count(*) from ppl.users where phone = phone_number) > 0 then
		RAISE EXCEPTION 'User with this phone already exists';
	end if;

	insert into ppl.users(firstname, lastname, phone_number, email) values(fname, lname, phone, mail);

	return (select id from ppl.users where mail = email); 
end;
$$
language plpgsql;


create or replace function ppl.add_courier(fname varchar, lname varchar, phone int, mail varchar, sal int)
	returns int as
$$
declare
	nid int;
begin
	if (select count(*) from ppl.couriers where phone = phone_number or email = mail) > 0 then
		RAISE EXCEPTION 'This courier already exists';
	end if;
	
	insert into ppl.couriers(firstname, lastname, phone_number, email, hour_salary) values(fname, lname, phone, mail, sal);
	nid = (select id from ppl.couriers where mail = email);	
	
	insert into ppl.couriers_schedule(id_courier, day) values(nid, 'MON');
	insert into ppl.couriers_schedule(id_courier, day) values(nid, 'TUE');
	insert into ppl.couriers_schedule(id_courier, day) values(nid, 'WED');
	insert into ppl.couriers_schedule(id_courier, day) values(nid, 'THU');
	insert into ppl.couriers_schedule(id_courier, day) values(nid, 'FRI');
	insert into ppl.couriers_schedule(id_courier, day) values(nid, 'SAT');
	insert into ppl.couriers_schedule(id_courier, day) values(nid, 'SUN');
	
	insert into ppl.couriers_statuses(courier_id, "from", "to") values(nid, CURRENT_TIMESTAMP, null); 
	
	return nid; 
end;
$$
language plpgsql;


--select * from ppl.parcel_history;


create or replace function ppl.check_pass_id(idg int, pass_hash int)
	returns void as
$$
declare
begin
	if (select count(*) from ppl.users where id = idg) = 0 then
		RAISE EXCEPTION 'This user doesn`t exist';
	end if;
	
	if (select password_hash from ppl.users where id = idg) != pass_hash then
			RAISE EXCEPTION 'Wrong password';
	end if;
end;
$$
language plpgsql;



create or replace function ppl.parcel_reg(we int, he int, len int, wid int, sendid int, sendaddre int, sedntyp varchar, recievid int, recaddre int, rectype varchar, parspeed varchar)
	returns void as
$$
declare
	u int;
	idg int;
begin
	insert into ppl.parcels(weight, height, length, width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed) values(we, he, len, wid, sendid, sendaddre, sedntyp, recievid, recaddre, rectype, parspeed);
	idg = currval('ppl.parcel_id');
	if (select  count(*) from ppl.parcels where id = idg) = 0 then
		RAISE EXCEPTION 'There is no such parcel';
	end if;
	u = nextval('ppl.status_id');
		insert into ppl.parcel_history(time, parcel_id, status_id, status_info_id) values (current_timestamp, idg, 0, u);
		insert into ppl.status_info_registered(id, id_place) values (u, null);
end;
$$
language plpgsql;



INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 1, 'Roman', 'Michalski', 487310572, 'xufh.vuhols@j-d--f.net', 0.17660208);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 2, 'Artur', 'Wisniewski', 480709920, 'mkuw@-fnvzo.com', 0.48890455);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 3, 'Kazimiera', 'Wroblewski', 480671200, 'jovo@k-v--p.com', 0.82630976);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 4, 'Magdalena', 'Marciniak', 487681569, 'vjwm.kqby@dcmr-i.net', 0.69771234);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 5, 'Stanislaw', 'Borkowski', 482273346, 'ujth@--h-ic.org', 0.34574726);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 6, 'Agnieszka', 'Baranowski', 486603195, 'igwd75@ul-mon.com', 0.2192445);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 7, 'Alicja', 'Jaworski', 488066734, 'krvv@h-skf-.net', 0.73152968);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 8, 'Barbara', 'Zalewski', 480298176, 'njia208@--u-yp.org', 0.2220016);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 9, 'Janusz', 'Kalinowski', 488111700, 'xnqr15@---il-.net', 0.02431375);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 10, 'Edyta', 'Michalski', 489454161, 'nguy65@qc---s.org', 0.39287644);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 11, 'Henryk', 'Szewczyk', 481527335, 'bjsq@---h-x.com', 0.66497052);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 12, 'Robert', 'Michalski', 489102761, 'sewx11@-j----.com', 0.28314894);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 13, 'Irena', 'Michalski', 489991461, 'nepr@-ws---.com', 0.06015437);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 14, 'Tadeusz', 'Nowak', 485399925, 'ffho@hbwi--.com', 0.51184878);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 15, 'Jerzy', 'Bak', 489775123, 'eizk311@--m---.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 16, 'Alicja', 'Michalski', 481584378, 'wdcw@une--b.com', 0.04016027);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 17, 'Damian', 'Gorski', 485490886, 'tqbo.wghrf@mycje.-lh-zp.org', 0.83695308);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 18, 'Jerzy', 'Sawicki', 480935458, 'dgnj.kvvfg@wn--cm.net', 0.35455215);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 19, 'Czeslaw', 'Bak', 484433903, 'hsutx@-rr-x-.net', 0.47383952);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 20, 'Zdzislaw', 'Kaczmarek', 484128618, 'nmsy@rke---.com', 0.34974193);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 21, 'Rafal', 'Majewski', 482864975, 'vylm454@----w-.net', 0.62638681);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 22, 'Justyna', 'Ostrowski', 481692378, 'joud@------.org', 0.03410703);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 23, 'Janina', 'Maciejewski', 484874575, 'rbrp.vwvsgd@-rkd-c.com', 0.16053811);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 24, 'Waldemar', 'Nowak', 489431688, 'asjb@--sc--.com', 0.03844291);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 25, 'Mateusz', 'Rutkowski', 488906095, 'qapcl09@-pdc--.com', 0.96547755);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 26, 'Marek', 'Zawadzki', 485357579, 'wdgas.qbqv@-zgs-r.com', 0.83345192);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 27, 'Daniel', 'Kolodziej', 485716704, 'xaem@dv-g-q.com', 0.80244633);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 28, 'Krzysztof', 'Szymanski', 482541151, 'rgbm8@--u-rq.com', 0.2738464);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 29, 'Natalia', 'Sikorski', 486907793, 'rjxs@----d-.net', 0.46851899);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 30, 'Katarzyna', 'Nowakowski', 489612111, 'bkcq7@n-----.org', 0.4756825);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 31, 'Krystyna', 'Krawczyk', 483337848, 'kxnf7@d-t-i-.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 32, 'Stanislaw', 'Jablonski', 482600071, 'mxlb@l---r-.com', 0.85791939);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 33, 'Anna', 'Pawlak', 484193775, 'vuzg.ckdym@k---h-.net', 0.30030874);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 34, 'Barbara', 'Wlodarczyk', 481253974, 'upvv72@-x--s-.com', 0.83636214);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 35, 'Tadeusz', 'Wisniewski', 487478607, 'vdzr821@u-w--o.org', 0.5660211);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 36, 'Tomasz', 'Wysocki', 484685740, 'nfdt3@tgc-f-.net', 0.18437898);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 37, 'Zdzislaw', 'Dudek', 481691625, 'gpfh5@g--dui.org', 0.38157596);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 38, 'Beata', 'Mazurek', 484514138, 'kcdc.gdhxx@-g--b-.com', 0.94386365);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 39, 'Marian', 'Maciejewski', 482830183, 'qejutw@---j-d.org', 0.08593455);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 40, 'Alicja', 'Sikora', 485011109, 'oyso@--chsz.com', 0.57403236);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 41, 'Jadwiga', 'Szczepanski', 485110870, 'eghi9@l-x--r.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 42, 'Michal', 'Chmielewski', 484983359, 'krko1@n----h.com', 0.77608992);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 43, 'Jacek', 'Baran', 483352534, 'gyym64@---zmq.net', 0.92168503);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 44, 'Natalia', 'Krawczyk', 483196490, 'mwdk25@----fb.org', 0.87719533);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 45, 'Jacek', 'Szewczyk', 488427614, 'stsl@--d---.com', 0.44991653);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 46, 'Damian', 'Michalski', 480538007, 'mohokh368@xc--g-.com', 0.01489213);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 47, 'Beata', 'Sikora', 488995078, 'idecik4@--m-qg.org', 0.11983433);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 48, 'Artur', 'Olszewski', 487321092, 'burl@ops-pz.com', 0.97130719);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 49, 'Anna', 'Czarnecki', 485583030, 'uqnl657@my-iiy.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 50, 'Jozef', 'Szymanski', 482186373, 'ufet.hiif@--k--d.com', 0.08260881);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 51, 'Piotr', 'Marciniak', 480478212, 'otupo522@cx-a-g.com', 0.06178188);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 52, 'Renata', 'Sokolowski', 481028351, 'ufwfq@p-p-py.net', 0.77315178);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 53, 'Rafal', 'Andrzejewski', 485570561, 'wjfw@k---n-.org', 0.46348861);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 54, 'Tomasz', 'Szulc', 485852601, 'tlcu.astjz@----j-.com', 0.06162443);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 55, 'Sylwia', 'Mazurek', 482842714, 'dquwq6@c---ei.org', 0.57417081);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 56, 'Genowefa', 'Kowalczyk', 487086006, 'htrcl1@--f--b.com', 0.16538588);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 57, 'Marcin', 'Rutkowski', 489416799, 'rzcf@-v---g.com', 0.3020294);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 58, 'Karolina', 'Malinowski', 480773598, 'urby745@------.net', 0.83155165);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 59, 'Agnieszka', 'Majewski', 482585488, 'dwph@-g----.com', 0.7427398);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 60, 'Wieslaw', 'Wojciechowski', 488491317, 'sfdv.epanmh@-gj-mo.org', 0.26990686);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 61, 'Anna', 'Szczepanski', 484953536, 'xnwo91@-evik-.com', 0.93358384);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 62, 'Andrzej', 'Czarnecki', 481404971, 'ipygx836@w----u.net', 0.53465848);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 63, 'Wladyslaw', 'Szymczak', 486373858, 'ofsh@-w--g-.com', 0.52615314);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 64, 'Kamil', 'Krawczyk', 486463761, 'utpb17@------.com', 0.50951607);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 65, 'Daniel', 'Malinowski', 486733607, 'jwlv.hdrsuc@--vp--.com', 0.4579037);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 66, 'Czeslaw', 'Wysocki', 487515271, 'cycc@e-v---.org', 0.86419455);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 67, 'Elzbieta', 'Baran', 481567024, 'lquv143@vq-l-k.org', 0.04483699);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 68, 'Monika', 'Sokolowski', 484482012, 'mzwj2@ieo---.org', 0.96998049);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 69, 'lukasz', 'Witkowski', 483960700, 'xija@ld-wx-.net', 0.32942877);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 70, 'Iwona', 'Nowicki', 481493491, 'ljhm@yar-zk.com', 0.93423411);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 71, 'Marek', 'Zalewski', 480072055, 'rwoe@-j-n-j.com', 0.55679499);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 72, 'Danuta', 'Szewczyk', 488898960, 'mmhfp@--ow-q.org', 0.95713284);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 73, 'Jadwiga', 'Wojciechowski', 488883377, 'lncm3@lj-k--.com', 0.99001526);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 74, 'Marcin', 'Kazmierczak', 482802986, 'ikdwz3@---r-p.com', 0.47905567);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 75, 'Marta', 'Kalinowski', 487423179, 'sive4@lo-r--.net', 0.20241184);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 76, 'Jakub', 'Kowalczyk', 489607969, 'qfuc.eusr@x---qq.org', 0.55999094);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 77, 'Damian', 'Brzezinski', 481746156, 'coyy253@-xfxh-.com', 0.51221282);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 78, 'Urszula', 'Wojciechowski', 486985691, 'jqgu.jiod@e--u-c.net', 0.63346552);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 79, 'Maria', 'Zalewski', 488396911, 'goit@-hh---.com', 0.98367439);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 80, 'Leszek', 'Sawicki', 488735531, 'cjpn@-c-i-p.com', 0.09822784);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 81, 'Artur', 'Adamski', 486095559, 'qteir9@-nuaz-.com', 0.00631056);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 82, 'Jerzy', 'Maciejewski', 480653711, 'mhww@--pa--.org', 0.67845658);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 83, 'Izabela', 'Jakubowski', 488961910, 'vhhf141@t--f-d.net', 0.62665532);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 84, 'Elzbieta', 'Andrzejewski', 481399936, 'cyxd@-m-cgt.com', 0.03424843);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 85, 'Roman', 'Malinowski', 480006617, 'gbgg@-a-zm-.com', 0.7995335);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 86, 'Henryk', 'Przybylski', 484501039, 'iwowp@i---b-.net', 0.79344338);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 87, 'Miroslaw', 'Wisniewski', 481911300, 'gupm@lw--v-.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 88, 'Sebastian', 'Maciejewski', 480202516, 'xqty@----x-.org', 0.37548835);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 89, 'Marek', 'Krawczyk', 484625400, 'qrhs757@-n-rb-.com', 0.46486483);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 90, 'Janina', 'Glowacki', 483526423, 'krkm.qtww@--i--r.com', 0.42561543);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 91, 'Irena', 'Zajac', 480136475, 'dfve.sncr@tjze.av-d-r.net', 0.18066668);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 92, 'Jolanta', 'Tomaszewski', 484307487, 'czud.kxtq@v--n--.com', 0.30576391);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 93, 'Mateusz', 'Maciejewski', 481315730, 'qvdl.tbdhhft@k-idp-.net', 0.88941475);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 94, 'Beata', 'Laskowski', 487379006, 'zlmpl@--i-mt.com', 0.58610221);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 95, 'Krzysztof', 'Krol', 487175280, 'bnsy531@-dqlhm.com', 0.56324166);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 96, 'Grazyna', 'Gajewski', 484718353, 'hbty333@i-ud--.net', 0.89061046);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 97, 'Maria', 'Wisniewski', 482653274, 'xsdm.bchcu@---fe-.com', 0.97659272);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 98, 'Maria', 'Krajewski', 484021683, 'dgeh6@zw-t--.com', 0.40107797);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 99, 'Sylwia', 'Wroblewski', 489403770, 'jtpvh396@xo--ge.com', 0.13007445);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 100, 'Jan', 'Szymczak', 489673296, 'yunt@-j-nq-.com', 0.09692112);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 101, 'Mateusz', 'Dudek', 480527860, 'cxhuq@bh-xkq.org', 0.98772395);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 102, 'Justyna', 'Pawlak', 486752721, 'vgqpt.xhrl@--xw--.com', 0.03327716);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 103, 'Przemyslaw', 'Nowakowski', 488039556, 'lhue7@du--t-.com', 0.74883766);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 104, 'Marian', 'Wieczorek', 487958946, 'arlvt@---wk-.net', 0.12666826);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 105, 'Przemyslaw', 'Szczepanski', 486694863, 'ghqo@e---w-.net', 0.13090117);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 106, 'Marianna', 'Wilk', 488034452, 'pahd@qqc---.net', 0.26873192);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 107, 'Elzbieta', 'Adamczyk', 481986122, 'rkbe82@tl-vw-.org', 0.33590172);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 108, 'Marzena', 'Marciniak', 483381338, 'yglt@q----h.com', 0.80908782);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 109, 'Malgorzata', 'Kucharski', 487259137, 'obyx@--ev--.com', 0.67975953);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 110, 'Kazimiera', 'Michalak', 483548536, 'semy@f-y--c.com', 0.96399203);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 111, 'Ryszard', 'Krajewski', 484471284, 'jrsed.fljqmcvhk@-smc--.org', 0.03143817);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 112, 'Maciej', 'Szulc', 480634848, 'nojn.cilf@r--eq-.com', 0.99366019);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 113, 'Andrzej', 'Kowalski', 482780031, 'hikv7@-tee--.org', 0.37002007);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 114, 'Renata', 'Nowak', 486430471, 'tmwra827@-x--z-.com', 0.53296643);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 115, 'Jozef', 'Mazur', 487419311, 'kgwb@------.com', 0.39196767);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 116, 'Zbigniew', 'Szewczyk', 481374363, 'ecfll.xxfofum@x---l-.net', 0.16186275);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 117, 'Jacek', 'Dabrowski', 489953591, 'kxcv.vqzd@-j-rs-.com', 0.00366308);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 118, 'Genowefa', 'Lewandowski', 484731792, 'ytxl@yaey-c.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 119, 'Jan', 'Kucharski', 487545043, 'fxyv.sihe@e---mf.net', 0.88933443);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 120, 'Henryk', 'Przybylski', 489422844, 'yicb5@h-q--n.net', 0.40485861);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 121, 'Elzbieta', 'Czarnecki', 489158169, 'wodl5@-vs---.com', 0.38723493);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 122, 'Malgorzata', 'Chmielewski', 484816508, 'sfhk@-n---l.org', 0.80121661);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 123, 'Edward', 'Pawlak', 487269685, 'iflr@jq-l-p.com', 0.7738357);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 124, 'Rafal', 'Szymczak', 485735948, 'xxfe.mkuojibl@-rwhr-.org', 0.30744331);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 125, 'Danuta', 'Jankowski', 484542178, 'kipqs.forv@sc----.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 126, 'Czeslaw', 'Grabowski', 489619133, 'lggh@-----d.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 127, 'Aleksandra', 'Adamski', 481731775, 'pmvs@p-id--.net', 0.31321087);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 128, 'Waldemar', 'Kowalski', 486997296, 'cdbf.kypbxye@--dk--.com', 0.61210246);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 129, 'Alicja', 'Kalinowski', 489787863, 'oele@e-----.com', 0.14774114);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 130, 'Helena', 'Wieczorek', 483474797, 'nueg.hypu@----gb.com', 0.56437706);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 131, 'Iwona', 'Wasilewski', 480403140, 'foul@-cp--a.com', 0.39606067);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 132, 'Kazimierz', 'Gorski', 486532434, 'effk@-e-e-c.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 133, 'Jan', 'Kaczmarek', 483202521, 'mcgf411@--xc--.net', 0.0839842);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 134, 'Krystyna', 'Malinowski', 484577645, 'rdes3@--il-f.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 135, 'Sebastian', 'Gajewski', 488118515, 'vtmm.xjqjdo@q---o-.org', 0.90265879);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 136, 'Pawel', 'Jankowski', 482606503, 'bhfn@eec---.com', 0.94658002);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 137, 'Adam', 'Czerwinski', 480368655, 'ngico@d--sci.com', 0.01329412);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 138, 'Mieczyslaw', 'Maciejewski', 482031967, 'erfd6@h-ny-j.com', 0.3894634);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 139, 'Danuta', 'Zakrzewski', 485688794, 'jsju2@-wmoc-.com', 0.37572945);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 140, 'Sylwia', 'Kucharski', 487110054, 'irqa11@-gjej-.com', 0.70956385);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 141, 'Artur', 'Wlodarczyk', 481227166, 'cqep.zvck@--s---.net', 0.81060045);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 142, 'Iwona', 'Kazmierczak', 486931148, 'hmut@--tr--.org', 0.83839333);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 143, 'Teresa', 'Pietrzak', 484691720, 'wyll132@-et-ce.com', 0.56586511);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 144, 'Jerzy', 'Wasilewski', 487139435, 'fxxu.orje@---nda.com', 0.89375531);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 145, 'Tadeusz', 'Ostrowski', 481172741, 'vlsx@-----h.net', 0.54470158);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 146, 'Edward', 'Nowicki', 485932784, 'vwqg3@--c-s-.com', 0.30192525);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 147, 'Miroslaw', 'Wojciechowski', 484520172, 'owsd44@nf---t.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 148, 'Sebastian', 'Zakrzewski', 483042593, 'yimiv4@s--d-v.com', 0.8190353);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 149, 'Damian', 'Borkowski', 482508170, 'nyim@h-l-sj.com', 0.75604452);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 150, 'Tadeusz', 'Jablonski', 481393973, 'jwev.slbx@-----x.com', 0.46847963);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 151, 'Przemyslaw', 'Dudek', 482316999, 'jvwi.hqqppj@n-z-y-.net', 0.67276507);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 152, 'Ewelina', 'Wrobel', 489128130, 'kgsl@-sp-so.org', 0.26056851);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 153, 'Dorota', 'Pawlak', 483434417, 'rqqn2@f-lg-t.com', 0.07958241);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 154, 'Leszek', 'Lis', 484289020, 'rete@t-t--w.net', 0.75112826);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 155, 'Maria', 'Zielinski', 488036701, 'nmyc56@--b-r-.com', 0.9017909);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 156, 'Marian', 'Kucharski', 487424854, 'rnxly7@-xepdh.net', 0.29141551);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 157, 'Jozef', 'Nowak', 486645842, 'lmrr84@-npmnp.org', 0.80650211);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 158, 'Adam', 'Wieczorek', 484852491, 'lynl@qp---k.org', 0.25201996);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 159, 'Ewa', 'Jakubowski', 487548086, 'jfiv@u-mfcp.com', 0.42086642);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 160, 'Jozef', 'Ostrowski', 480631072, 'buia@-ek--c.com', 0.03225009);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 161, 'Stefania', 'Rutkowski', 488555055, 'bwsz7@imd-je.com', 0.27008296);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 162, 'Pawel', 'Brzezinski', 481173740, 'rllq@--mwl-.com', 0.03501298);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 163, 'Jozef', 'Chmielewski', 486428343, 'lbiw@-s-sar.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 164, 'Stefania', 'Czerwinski', 487707273, 'juak1@-ez---.com', 0.39776282);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 165, 'Kamil', 'Maciejewski', 483189435, 'shvd@--w--b.net', 0.06921054);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 166, 'Patrycja', 'Dabrowski', 487814753, 'ytzwv.jqlth@e-----.com', 0.27304274);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 167, 'Mieczyslaw', 'Stepien', 485897831, 'lhxb@-----u.org', 0.20780501);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 168, 'Patrycja', 'Ziolkowski', 484442863, 'vrvoz7@zatd--.com', 0.38043562);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 169, 'Artur', 'Cieslak', 481881468, 'fraqt5@yujl-o.net', 0.46779876);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 170, 'Paulina', 'Wieczorek', 484931357, 'yrsk@-iun-i.org', 0.70832331);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 171, 'Jacek', 'Krajewski', 480206162, 'wgqo@-k--r-.com', 0.38793541);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 172, 'Elzbieta', 'Kwiatkowski', 481766984, 'tums@y-r--k.net', 0.73868121);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 173, 'Ewelina', 'Jablonski', 481017606, 'popg.ucdh@-gvac-.net', 0.44742455);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 174, 'Paulina', 'Marciniak', 483348524, 'tjnomju5@-u----.org', 0.97454548);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 175, 'Czeslaw', 'Adamczyk', 481704048, 'xqjr541@a-y-o-.net', 0.65980379);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 176, 'Mariusz', 'Rutkowski', 486575505, 'hhzs29@bjk--r.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 177, 'Mariusz', 'Krawczyk', 485315427, 'yoiv@-uih--.com', 0.70442286);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 178, 'Karolina', 'Adamski', 482573734, 'vtwa862@--oq-f.com', 0.85815176);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 179, 'Sebastian', 'Nowak', 485821647, 'nftis.srwr@---kxt.net', 0.69052728);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 180, 'Elzbieta', 'Adamczyk', 483410634, 'qqdn@doi-r-.net', 0.92813727);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 181, 'Aneta', 'Ostrowski', 483366470, 'lzxf475@-m--wa.com', 0.80788775);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 182, 'Aneta', 'Walczak', 486828034, 'hgck@fr-ute.org', 0.09387573);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 183, 'Paulina', 'Urbanski', 483223022, 'bofc7@-wz-vw.com', 0.37102093);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 184, 'Barbara', 'Sikorski', 480456598, 'vystj@y-ju-t.net', 0.79429271);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 185, 'Daniel', 'Baran', 485512190, 'wcqg@v--pcw.com', 0.12014482);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 186, 'Jakub', 'Zawadzki', 488832659, 'guvw@-y-a--.com', 0.89657697);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 187, 'Iwona', 'Kowalczyk', 480517614, 'dbpw@z-b--a.com', 0.80321274);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 188, 'Zofia', 'Michalak', 480004298, 'uzir.txse@-ave--.org', 0.05663281);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 189, 'Katarzyna', 'Wilk', 481513043, 'qqmw@-b---o.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 190, 'Waldemar', 'Wisniewski', 482309760, 'ttkl@-i--d-.org', 0.71284434);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 191, 'Mieczyslaw', 'Pawlowski', 484083494, 'whcg9@p-tmog.com', 0.1142532);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 192, 'Michal', 'Jankowski', 481789767, 'qpnj@-o---w.com', 0.74354445);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 193, 'Wanda', 'Chmielewski', 486925818, 'qhxo1@n--ark.org', 0.69837953);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 194, 'Renata', 'Krol', 481939009, 'ebdqe@rk--p-.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 195, 'Krystyna', 'Sadowski', 483793468, 'mnyl.lguup@niot.---b--.com', 0.8806888);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 196, 'Justyna', 'Pawlak', 487425750, 'joew@-q----.com', 0.6195727);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 197, 'Slawomir', 'Piotrowski', 482621886, 'qyvr@y--s--.com', 0.96705977);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 198, 'Jadwiga', 'Jablonski', 483857543, 'tiwn250@x-rx-g.com', 0.31775253);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 199, 'Zofia', 'Kaminski', 484733925, 'uzdb@xx-bck.com', 0.18371929);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 200, 'Zbigniew', 'Krawczyk', 485522637, 'cyvn@--k-o-.net', 0.92426596);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 201, 'Czeslaw', 'Walczak', 481459111, 'lkhe@xpj-dx.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 202, 'Ewa', 'Kowalski', 480698907, 'ebes8@-fico-.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 203, 'Kamil', 'Sawicki', 485367679, 'cyqb.xydy@f---qo.com', 0.00946165);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 204, 'Wanda', 'Bak', 480034468, 'ytzw.hxatg@-o---w.com', 0.22925925);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 205, 'Katarzyna', 'Przybylski', 489762783, 'ynbp@-c---e.com', 0.64271829);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 206, 'Ryszard', 'Pawlowski', 482637368, 'rtku@to-t-r.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 207, 'Justyna', 'Kowalski', 480015862, 'tprh5@z-k-a-.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 208, 'Irena', 'Krawczyk', 488867666, 'lnwz.tmtqpdo@sv-avn.com', 0.65773857);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 209, 'Halina', 'Pawlowski', 488975965, 'qqek.ocbsiv@w---kb.org', 0.59994223);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 210, 'Genowefa', 'Urbanski', 489937187, 'obep@-p-x-x.org', 0.41884322);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 211, 'Przemyslaw', 'Zakrzewski', 482020243, 'rcgc314@-ho-e-.com', 0.12575891);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 212, 'Mieczyslaw', 'Kwiatkowski', 485854617, 'ytcjt1@nj-yi-.org', 0.95015382);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 213, 'Sylwia', 'Jakubowski', 484607247, 'byec.ghjcf@l--ptw.org', 0.14299189);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 214, 'Miroslaw', 'Czerwinski', 483102099, 'wohc.htbiv@m---ih.org', 0.3951886);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 215, 'Dariusz', 'Sobczak', 481496217, 'gwpe5@w----q.org', 0.8773051);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 216, 'Daniel', 'Borkowski', 486821140, 'show@-h---h.com', 0.14419506);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 217, 'Kamil', 'Urbanski', 485433983, 'dwqu5@-u--gs.com', 0.39373716);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 218, 'Tadeusz', 'Ziolkowski', 483878496, 'icdz@vtx--u.net', 0.33640659);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 219, 'Mateusz', 'Wisniewski', 488197976, 'rpag@d-ym-x.org', 0.7910622);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 220, 'Anna', 'Kozlowski', 489666390, 'vpod@-mrhkg.org', 0.8571299);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 221, 'Stanislaw', 'Majewski', 485811661, 'nfqf.nulbdnrb@----o-.net', 0.85583945);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 222, 'Zdzislaw', 'Jablonski', 484086500, 'bish@---i--.com', 0.97631895);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 223, 'Henryk', 'Bak', 485691269, 'hhey.fwolcvdr@ri-p--.net', 0.47274107);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 224, 'Wojciech', 'Mazurek', 489125655, 'heqj@-b-ill.com', 0.84264075);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 225, 'Aneta', 'Pietrzak', 487895116, 'dosd018@iweg--.net', 0.94664245);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 226, 'Marcin', 'Lis', 489536301, 'yvzk@c-q---.net', 0.98675623);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 227, 'Jan', 'Jablonski', 487765427, 'vgik58@--u-l-.com', 0.33150774);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 228, 'Rafal', 'Witkowski', 489200962, 'qsnp@----x-.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 229, 'Urszula', 'Jankowski', 488594898, 'kkkuv@g-rmow.org', 0.89153303);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 230, 'Dariusz', 'Zajac', 483132845, 'bqul1@inoie-.net', 0.49701409);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 231, 'Zbigniew', 'Cieslak', 481815198, 'kpuh7@s-x--d.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 232, 'Marian', 'Kozlowski', 480121393, 'xmcv6@o-ej-l.com', 0.29159925);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 233, 'Jan', 'Chmielewski', 488172187, 'qqiav@-lxvm-.com', 0.33008882);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 234, 'Beata', 'Gajewski', 484680177, 'vssp.jiem@-dg---.com', 0.71981042);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 235, 'Patrycja', 'Kolodziej', 486784240, 'ippc.opykdl@b-vqz-.org', 0.77153312);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 236, 'Helena', 'Wojciechowski', 482134409, 'ggio@--qm-m.org', 0.67368358);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 237, 'Agata', 'Nowicki', 483518190, 'jwsjp.xblk@-m-fpi.com', 0.49305477);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 238, 'Elzbieta', 'Duda', 484867426, 'wfyi@e-uffw.com', 0.73522451);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 239, 'Marianna', 'Piotrowski', 485185971, 'rpxb@-bt-z-.net', 0.77176395);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 240, 'Wladyslaw', 'Sobczak', 485431500, 'rmtw.rgvw@-hk-c-.com', 0.32895454);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 241, 'Izabela', 'Brzezinski', 489369082, 'irhx5@d--y--.com', 0.59622747);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 242, 'Agata', 'Nowicki', 487451626, 'ejnh@rk----.org', 0.13750752);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 243, 'Janusz', 'Sokolowski', 489703770, 'adxsm1@n----d.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 244, 'Henryk', 'Kucharski', 484075877, 'jgti@oe-v-f.org', 0.41529653);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 245, 'Leszek', 'Majewski', 484975093, 'rjwt@-q-om-.org', 0.30467485);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 246, 'Edyta', 'Grabowski', 486748286, 'pgit0@-ebh-g.com', 0.71620362);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 247, 'Marcin', 'Szewczyk', 484921394, 'aigg@cpg---.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 248, 'Jerzy', 'Grabowski', 481926891, 'ayix737@----di.com', 0.87498464);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 249, 'Rafal', 'Dabrowski', 482072436, 'sjyh@--l-ck.net', 0.57431657);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 250, 'Kazimiera', 'Dudek', 487198792, 'yegl7@d-c--g.net', 0.37390971);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 251, 'Agata', 'Grabowski', 483845762, 'tyvu907@-b-s-x.net', 0.99289527);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 252, 'Teresa', 'Grabowski', 480245344, 'cpil@---k-p.net', 0.48794778);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 253, 'Zofia', 'Walczak', 482399348, 'vvhn@-ubh--.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 254, 'Daniel', 'Zawadzki', 488004476, 'nile7@-g--v-.com', 0.96842352);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 255, 'Edyta', 'Lewandowski', 487058123, 'mkkq219@-----p.com', 0.31925697);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 256, 'Wieslaw', 'Kaczmarek', 489915772, 'oxox.etwi@----m-.org', 0.3096053);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 257, 'Grzegorz', 'Wisniewski', 489452609, 'qxzk@--plwf.com', 0.11371314);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 258, 'Katarzyna', 'Kolodziej', 488600338, 'xvdf1@-yoran.com', 0.87377594);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 259, 'Waldemar', 'Mazur', 489565915, 'zvnf577@n-hchh.net', 0.54702442);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 260, 'Grazyna', 'Wasilewski', 486036251, 'bcdjk5@w-i-pg.com', 0.74607163);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 261, 'lukasz', 'Czerwinski', 489698438, 'bvrg06@v--e-v.org', 0.39542956);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 262, 'Alicja', 'Baranowski', 480087149, 'gsxy@ag-y--.net', 0.69446556);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 263, 'Zbigniew', 'Szczepanski', 486726481, 'dkeg@fisa-w.org', 0.55282133);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 264, 'Mariusz', 'Wasilewski', 489003228, 'yylb@-b-p-o.org', 0.83993434);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 265, 'Andrzej', 'Marciniak', 483031798, 'cshn@-gpbtn.com', 0.59737209);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 266, 'Jadwiga', 'Przybylski', 483648839, 'mtlr328@wb--xg.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 267, 'Daniel', 'Sadowski', 485975135, 'bbwk@---p--.com', 0.18703104);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 268, 'Irena', 'Wrobel', 484158345, 'ymrc9@y--r-j.net', 0.090806);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 269, 'Wladyslaw', 'Sobczak', 480920683, 'espkok5@pb---m.com', 0.79874252);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 270, 'Waldemar', 'Pietrzak', 489452809, 'cdyd6@p-l-o-.net', 0.32885422);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 271, 'Malgorzata', 'Sawicki', 485513856, 'gfcp8@---l--.com', 0.54730956);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 272, 'Ewelina', 'Kaczmarek', 481566143, 'wjotd627@k-a-fe.net', 0.17174749);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 273, 'Beata', 'Piotrowski', 483377051, 'pyye48@b---h-.com', 0.86154672);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 274, 'Andrzej', 'Wrobel', 488563971, 'hiay@---l--.com', 0.51514089);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 275, 'Krzysztof', 'Zakrzewski', 484603296, 'zuov280@-v---c.com', 0.65684839);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 276, 'Janina', 'Glowacki', 488556029, 'dlkv575@o---x-.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 277, 'Krystyna', 'Szymanski', 482663649, 'ukok3@-pvkpg.net', 0.90879956);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 278, 'Malgorzata', 'Baran', 485999040, 'qjpo@o--g-f.org', 0.10137634);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 279, 'Damian', 'Zielinski', 482649520, 'soxiuh5@h-l-mm.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 280, 'Karolina', 'Mazur', 480288808, 'ejpoqk@mz-jb-.com', 0.69962307);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 281, 'Barbara', 'Sawicki', 482476037, 'ssox@j---rk.com', 0.95643577);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 282, 'Krzysztof', 'Glowacki', 485205833, 'afoz5@----u-.com', 0.90279811);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 283, 'Dariusz', 'Piotrowski', 485888315, 'moakr.ugfbyn@z-h--d.net', 0.87460532);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 284, 'Aleksandra', 'Jankowski', 487797543, 'vabd@o-iv-h.com', 0.04579707);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 285, 'Elzbieta', 'Sokolowski', 486231720, 'peqn@--v-dh.com', 0.31240106);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 286, 'Malgorzata', 'Sawicki', 482972982, 'gvhe@l---vq.net', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 287, 'Roman', 'Pietrzak', 481143667, 'idqx66@e-kovz.net', 0.77272363);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 288, 'Karolina', 'Nowicki', 488704497, 'coch904@tl---x.com', 0.82843139);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 289, 'Sylwia', 'Stepien', 487053361, 'svae.kyts@-j----.com', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 290, 'Marcin', 'Witkowski', 489058696, 'dexy@---p-g.com', 0.29002566);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 291, 'Izabela', 'Rutkowski', 485873360, 'gjqock@-p-vqp.org', 0.91291694);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 292, 'Elzbieta', 'Laskowski', 483130276, 'qnzgj.mhiw@---ddg.org', 0.64111232);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 293, 'Adam', 'Sadowski', 485050617, 'lunf2@nxjyl-.org', 0.75002324);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 294, 'Iwona', 'Adamczyk', 486672933, 'tutg52@----bk.org', null);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 295, 'Sylwia', 'Sokolowski', 482513493, 'jkit85@-sl---.com', 0.09226077);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 296, 'Kazimierz', 'Olszewski', 486188353, 'wmuc28@k-pfgc.net', 0.44892205);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 297, 'Rafal', 'Bak', 484585248, 'djztndf@x-c--n.net', 0.16475017);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 298, 'Zdzislaw', 'Szulc', 488355499, 'ewok01@-qt-wc.com', 0.08684011);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 299, 'Tadeusz', 'Kaminski', 482994998, 'wewf@-kmc--.com', 0.46419847);
INSERT INTO ppl.couriers( id, firstname, lastname, phone_number, email, hour_salary ) VALUES ( 300, 'Slawomir', 'Adamczyk', 488897529, 'ayeu@------.net', 0.41793777);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 166, 'WED', 5, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 180, 'THU', 18, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 100, 'WED', 1, 4);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 76, 'MON', 17, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 116, 'SAT', 20, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 296, 'SAT', 10, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 53, 'SUN', 1, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 39, 'WED', 5, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 212, 'SUN', 6, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 165, 'TUE', 6, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 32, 'FRI', 3, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 188, 'WED', 1, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 233, 'FRI', 5, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 294, 'SAT', 3, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 298, 'WED', 1, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 147, 'SAT', 1, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 224, 'MON', 11, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 220, 'TUE', 19, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 246, 'FRI', 8, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 159, 'THU', 4, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 218, 'FRI', 4, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 270, 'WED', 4, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 41, 'WED', 2, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 56, 'TUE', 13, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 217, 'WED', 14, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 20, 'WED', 1, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 108, 'MON', 9, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 201, 'FRI', 18, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 105, 'TUE', 0, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 182, 'THU', 15, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 258, 'THU', 4, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 280, 'MON', 12, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 260, 'FRI', 18, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 62, 'FRI', 4, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 208, 'WED', 13, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 285, 'MON', 7, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 214, 'MON', 9, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 207, 'THU', 10, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 119, 'MON', 6, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 284, 'FRI', 8, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 186, 'MON', 2, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 119, 'WED', 5, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 184, 'MON', 8, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 279, 'FRI', 1, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 299, 'FRI', 14, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 265, 'SUN', 13, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 144, 'FRI', 6, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 52, 'WED', 2, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 44, 'SAT', 13, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 58, 'TUE', 5, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 218, 'WED', 13, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 204, 'TUE', 10, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 198, 'THU', 10, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 142, 'THU', 4, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 291, 'FRI', 0, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 113, 'WED', 2, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 15, 'THU', 10, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 237, 'THU', 6, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 1, 'SAT', 12, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 34, 'WED', 0, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 145, 'MON', 12, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 105, 'FRI', 3, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 231, 'SAT', 12, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 216, 'MON', 5, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 151, 'MON', 3, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 93, 'FRI', 15, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 218, 'TUE', 11, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 16, 'TUE', 3, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 57, 'THU', 12, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 4, 'TUE', 0, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 59, 'SUN', 0, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 107, 'THU', 1, 5);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 247, 'MON', 0, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 251, 'TUE', 4, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 223, 'WED', 2, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 93, 'MON', 4, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 91, 'WED', 0, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 94, 'MON', 7, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 263, 'WED', 12, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 150, 'SAT', 4, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 153, 'THU', 2, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 61, 'WED', 9, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 144, 'TUE', 4, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 212, 'MON', 1, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 83, 'SUN', 5, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 4, 'WED', 20, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 288, 'THU', 16, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 229, 'SUN', 2, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 71, 'MON', 6, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 171, 'TUE', 6, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 117, 'MON', 1, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 51, 'WED', 11, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 175, 'SAT', 3, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 2, 'THU', 12, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 179, 'SUN', 10, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 18, 'MON', 1, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 227, 'WED', 7, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 129, 'THU', 3, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 123, 'WED', 5, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 202, 'MON', 4, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 105, 'MON', 11, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 223, 'SAT', 16, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 252, 'SAT', 4, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 13, 'FRI', 2, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 163, 'WED', 3, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 185, 'MON', 7, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 292, 'THU', 14, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 7, 'SUN', 7, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 185, 'WED', 19, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 124, 'FRI', 19, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 9, 'TUE', 1, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 207, 'FRI', 13, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 91, 'THU', 19, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 96, 'THU', 3, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 125, 'SAT', 14, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 7, 'WED', 9, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 214, 'SAT', 1, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 198, 'FRI', 5, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 94, 'TUE', 3, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 177, 'MON', 7, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 35, 'THU', 3, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 92, 'MON', 20, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 206, 'FRI', 8, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 246, 'MON', 4, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 77, 'MON', 10, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 14, 'TUE', 16, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 65, 'WED', 7, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 187, 'SAT', 9, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 101, 'MON', 1, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 76, 'WED', 5, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 221, 'MON', 1, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 90, 'FRI', 16, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 24, 'FRI', 5, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 228, 'FRI', 0, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 14, 'WED', 9, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 213, 'WED', 8, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 26, 'TUE', 14, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 283, 'SAT', 19, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 26, 'WED', 5, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 221, 'WED', 4, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 53, 'FRI', 16, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 54, 'FRI', 4, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 3, 'WED', 18, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 82, 'MON', 10, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 72, 'THU', 3, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 154, 'MON', 9, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 284, 'TUE', 9, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 66, 'FRI', 13, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 83, 'MON', 10, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 108, 'WED', 3, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 277, 'MON', 5, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 43, 'FRI', 8, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 203, 'WED', 8, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 188, 'TUE', 6, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 28, 'WED', 2, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 276, 'WED', 14, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 176, 'THU', 9, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 202, 'SUN', 7, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 220, 'MON', 3, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 168, 'THU', 13, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 62, 'TUE', 11, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 45, 'WED', 1, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 212, 'FRI', 6, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 64, 'MON', 14, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 141, 'TUE', 1, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 173, 'WED', 4, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 242, 'FRI', 5, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 290, 'SAT', 2, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 42, 'MON', 9, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 30, 'WED', 6, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 201, 'WED', 14, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 129, 'WED', 12, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 74, 'MON', 6, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 132, 'SUN', 15, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 59, 'MON', 10, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 40, 'WED', 3, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 210, 'WED', 7, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 207, 'WED', 1, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 46, 'TUE', 8, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 217, 'MON', 17, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 201, 'THU', 11, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 157, 'TUE', 20, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 287, 'THU', 2, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 86, 'MON', 9, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 295, 'TUE', 6, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 152, 'FRI', 19, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 1, 'MON', 2, 4);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 184, 'TUE', 2, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 63, 'SUN', 8, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 41, 'TUE', 6, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 10, 'MON', 5, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 72, 'WED', 3, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 26, 'SAT', 15, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 251, 'MON', 11, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 122, 'MON', 9, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 67, 'MON', 5, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 56, 'WED', 8, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 89, 'THU', 7, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 173, 'MON', 12, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 116, 'THU', 9, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 112, 'TUE', 8, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 71, 'FRI', 23, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 162, 'MON', 4, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 267, 'MON', 6, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 83, 'WED', 12, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 202, 'TUE', 9, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 137, 'MON', 9, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 33, 'FRI', 11, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 281, 'MON', 5, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 137, 'SAT', 6, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 111, 'WED', 5, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 119, 'FRI', 8, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 108, 'TUE', 16, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 2, 'FRI', 2, 5);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 90, 'MON', 1, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 11, 'MON', 15, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 237, 'WED', 4, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 126, 'THU', 4, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 88, 'SUN', 2, 4);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 102, 'WED', 11, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 245, 'SAT', 22, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 79, 'TUE', 1, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 169, 'TUE', 5, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 267, 'WED', 6, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 125, 'TUE', 16, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 247, 'FRI', 3, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 263, 'TUE', 6, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 219, 'FRI', 8, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 232, 'THU', 3, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 110, 'MON', 13, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 69, 'WED', 5, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 269, 'FRI', 9, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 106, 'THU', 2, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 73, 'WED', 5, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 36, 'WED', 8, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 289, 'WED', 15, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 186, 'WED', 1, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 50, 'WED', 4, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 10, 'SUN', 15, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 143, 'MON', 3, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 68, 'WED', 3, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 43, 'MON', 2, 4);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 95, 'SUN', 5, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 164, 'WED', 8, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 111, 'TUE', 7, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 187, 'TUE', 1, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 66, 'MON', 14, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 75, 'THU', 11, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 231, 'WED', 11, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 274, 'TUE', 6, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 159, 'TUE', 5, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 263, 'SUN', 7, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 32, 'THU', 6, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 177, 'FRI', 1, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 126, 'TUE', 9, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 127, 'WED', 4, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 201, 'MON', 6, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 167, 'MON', 15, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 223, 'TUE', 10, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 276, 'THU', 11, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 113, 'FRI', 0, 4);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 282, 'MON', 2, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 51, 'SAT', 13, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 99, 'FRI', 1, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 245, 'THU', 5, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 52, 'THU', 1, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 109, 'THU', 10, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 113, 'SAT', 6, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 232, 'SAT', 3, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 157, 'MON', 2, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 201, 'TUE', 2, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 184, 'FRI', 9, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 86, 'WED', 2, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 95, 'FRI', 1, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 88, 'WED', 2, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 28, 'MON', 13, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 103, 'SAT', 7, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 264, 'FRI', 3, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 195, 'THU', 12, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 178, 'TUE', 9, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 112, 'THU', 3, 5);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 54, 'WED', 2, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 124, 'MON', 6, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 283, 'SUN', 15, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 285, 'THU', 11, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 9, 'WED', 2, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 197, 'TUE', 2, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 57, 'SAT', 4, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 55, 'FRI', 17, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 287, 'MON', 4, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 190, 'MON', 15, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 235, 'MON', 8, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 43, 'SAT', 17, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 300, 'THU', 7, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 250, 'THU', 8, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 277, 'SAT', 2, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 207, 'MON', 1, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 121, 'THU', 1, 2);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 143, 'FRI', 13, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 88, 'MON', 8, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 250, 'MON', 17, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 26, 'MON', 15, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 222, 'MON', 6, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 196, 'TUE', 13, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 158, 'MON', 14, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 179, 'MON', 0, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 79, 'WED', 2, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 87, 'FRI', 5, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 67, 'SAT', 7, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 145, 'TUE', 3, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 147, 'MON', 7, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 206, 'SAT', 10, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 31, 'WED', 13, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 227, 'THU', 15, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 137, 'WED', 1, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 292, 'MON', 19, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 130, 'WED', 5, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 141, 'WED', 13, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 182, 'MON', 1, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 95, 'TUE', 0, 3);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 86, 'TUE', 17, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 8, 'TUE', 3, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 114, 'TUE', 0, 3);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 238, 'MON', 14, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 58, 'THU', 1, 2);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 2, 'SAT', 5, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 110, 'SAT', 8, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 16, 'WED', 10, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 118, 'SUN', 19, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 28, 'FRI', 0, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 206, 'WED', 18, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 11, 'WED', 3, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 76, 'FRI', 1, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 279, 'SUN', 17, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 278, 'WED', 1, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 196, 'THU', 9, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 227, 'TUE', 8, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 34, 'THU', 9, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 74, 'SAT', 1, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 134, 'WED', 2, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 92, 'FRI', 10, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 19, 'THU', 22, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 154, 'WED', 8, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 92, 'WED', 15, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 175, 'WED', 7, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 136, 'MON', 2, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 63, 'MON', 22, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 295, 'MON', 12, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 256, 'THU', 16, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 17, 'FRI', 17, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 178, 'THU', 0, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 161, 'MON', 8, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 293, 'SUN', 0, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 198, 'MON', 4, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 153, 'WED', 3, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 152, 'WED', 5, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 260, 'THU', 3, 5);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 240, 'SAT', 11, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 292, 'WED', 8, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 204, 'SUN', 1, 2);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 243, 'THU', 7, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 95, 'THU', 3, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 136, 'THU', 9, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 199, 'THU', 0, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 276, 'FRI', 17, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 104, 'MON', 1, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 139, 'TUE', 9, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 97, 'WED', 4, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 144, 'WED', 15, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 54, 'SAT', 16, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 82, 'TUE', 8, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 178, 'FRI', 2, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 24, 'WED', 4, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 211, 'MON', 11, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 181, 'WED', 8, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 142, 'WED', 7, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 100, 'MON', 4, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 232, 'WED', 8, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 240, 'MON', 15, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 205, 'THU', 2, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 121, 'TUE', 9, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 270, 'MON', 16, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 208, 'MON', 9, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 110, 'WED', 5, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 222, 'WED', 21, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 52, 'SUN', 19, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 2, 'SUN', 2, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 253, 'THU', 19, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 146, 'WED', 1, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 129, 'MON', 23, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 290, 'MON', 7, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 246, 'SAT', 2, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 172, 'WED', 17, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 72, 'MON', 0, 6);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 130, 'FRI', 7, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 252, 'THU', 6, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 6, 'MON', 10, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 121, 'WED', 4, 22);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 125, 'MON', 2, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 122, 'TUE', 3, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 174, 'FRI', 15, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 148, 'THU', 8, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 242, 'SAT', 14, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 146, 'TUE', 1, 8);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 180, 'TUE', 14, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 245, 'WED', 2, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 263, 'THU', 13, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 31, 'MON', 15, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 24, 'TUE', 1, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 173, 'FRI', 2, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 115, 'WED', 8, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 214, 'WED', 4, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 179, 'WED', 17, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 299, 'THU', 6, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 6, 'WED', 9, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 180, 'WED', 1, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 262, 'FRI', 1, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 270, 'TUE', 6, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 283, 'WED', 12, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 249, 'THU', 15, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 220, 'WED', 10, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 138, 'MON', 5, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 170, 'THU', 5, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 12, 'WED', 15, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 55, 'TUE', 16, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 231, 'MON', 11, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 30, 'FRI', 7, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 261, 'TUE', 3, 7);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 77, 'WED', 7, 13);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 255, 'WED', 2, 14);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 97, 'MON', 7, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 248, 'TUE', 9, 15);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 183, 'MON', 4, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 121, 'SAT', 6, 11);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 107, 'MON', 8, 20);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 253, 'TUE', 18, 24);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 226, 'SUN', 4, 12);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 58, 'SUN', 12, 19);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 174, 'WED', 14, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 140, 'FRI', 7, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 124, 'TUE', 1, 3);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 193, 'MON', 3, 9);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 35, 'MON', 18, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 47, 'TUE', 3, 18);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 78, 'TUE', 12, 17);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 191, 'WED', 3, 23);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 71, 'WED', 6, 10);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 253, 'WED', 12, 16);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 249, 'WED', 17, 21);
INSERT INTO ppl.couriers_schedule( id_courier, "day", "from", "until" ) VALUES ( 5, 'MON', 15, 16);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 73, '2013-12-01 02:36:37 AM', '2020-05-01 04:11:00 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 192, '2010-12-30 03:33:34 PM', '2021-04-26 08:52:45 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 93, '2008-07-10 12:00:31 AM', '2014-07-14 01:46:48 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 235, '2018-04-03 02:38:15 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 100, '2008-02-02 05:41:34 AM', '2015-12-28 06:27:35 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 76, '2010-03-15 09:55:09 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 184, '2010-04-21 12:16:11 AM', '2019-05-01 06:24:18 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 295, '2015-12-29 10:30:17 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 264, '2021-08-31 05:15:47 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 53, '2015-01-10 10:19:29 PM', '2017-09-22 06:30:24 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 39, '2013-01-05 09:44:04 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 212, '2013-04-28 04:04:15 PM', '2016-07-23 08:53:40 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 7, '2015-04-23 04:32:31 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 1, '2020-06-21 05:24:43 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 3, '2015-10-12 10:01:02 PM', '2021-11-27 07:55:11 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 169, '2016-06-01 07:00:28 AM', '2016-11-23 04:13:05 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 32, '2017-07-09 03:33:45 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 188, '2010-04-06 02:11:10 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 86, '2018-12-27 11:50:40 PM', '2020-02-10 09:25:13 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 294, '2020-09-07 05:17:35 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 207, '2014-06-30 04:10:11 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 147, '2019-08-14 01:24:01 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 261, '2008-01-26 01:44:36 PM', '2021-06-16 03:13:59 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 224, '2008-01-27 11:34:32 AM', '2011-11-07 03:59:43 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 220, '2015-07-19 10:36:35 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 172, '2008-05-03 10:53:11 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 246, '2018-09-25 07:24:33 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 4, '2018-03-04 08:57:18 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 218, '2009-02-01 06:58:13 AM', '2014-08-22 08:34:12 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 41, '2016-04-29 08:03:24 AM', '2019-05-22 08:13:49 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 164, '2021-10-11 11:40:45 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 25, '2010-12-15 09:15:12 PM', '2016-05-29 05:06:41 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 217, '2010-08-31 10:33:47 AM', '2014-03-09 01:33:55 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 202, '2008-01-07 08:14:20 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 43, '2010-04-28 05:35:36 PM', '2016-02-17 03:36:49 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 139, '2010-07-27 09:11:41 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 83, '2015-01-13 04:24:20 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 2, '2015-10-18 09:52:40 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 201, '2009-10-29 01:04:17 AM', '2021-01-20 01:20:05 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 105, '2011-07-17 10:18:14 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 245, '2010-12-23 01:34:03 AM', '2016-12-15 11:41:13 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 102, '2013-09-10 03:36:18 AM', '2020-08-01 02:06:46 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 182, '2020-03-14 01:40:25 PM', '2021-07-22 02:09:04 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 258, '2011-02-20 06:05:36 PM', '2011-07-08 09:36:34 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 292, '2014-03-26 03:47:36 PM', '2014-08-24 06:21:59 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 260, '2011-05-13 06:18:40 PM', '2019-07-19 01:08:45 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 14, '2013-08-02 08:02:55 PM', '2018-07-27 10:12:28 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 54, '2008-07-21 12:32:33 AM', '2018-03-04 02:16:15 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 94, '2011-11-30 06:28:44 PM', '2015-09-01 11:17:45 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 62, '2009-08-17 02:27:17 PM', '2021-09-13 03:01:15 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 125, '2022-04-24 05:15:05 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 232, '2022-03-15 08:09:47 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 214, '2010-12-25 11:56:49 AM', '2011-11-22 09:31:16 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 64, '2013-05-28 10:17:25 AM', '2019-09-26 11:53:45 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 231, '2012-03-12 03:30:36 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 5, '2014-05-24 06:04:07 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 186, '2008-09-28 04:08:07 AM', '2016-06-06 05:06:33 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 257, '2022-05-31 03:05:08 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 236, '2017-02-04 04:58:21 AM', '2018-10-29 01:08:06 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 95, '2012-12-01 02:34:58 PM', '2021-10-17 11:44:45 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 144, '2011-11-01 04:47:28 PM', '2020-04-10 07:57:30 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 52, '2015-02-02 10:15:22 PM', '2021-09-19 10:34:01 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 44, '2009-09-06 09:20:13 PM', '2012-11-15 08:38:41 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 289, '2014-03-09 04:11:12 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 272, '2015-11-17 08:50:11 PM', '2019-07-19 08:35:50 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 87, '2015-02-19 02:57:48 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 198, '2008-03-22 01:48:01 AM', '2012-08-16 10:16:03 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 133, '2011-01-09 12:25:31 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 256, '2015-12-02 10:57:33 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 151, '2016-01-06 07:05:00 AM', '2022-02-06 08:29:14 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 113, '2013-03-12 11:22:41 AM', '2016-01-27 01:15:47 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 15, '2010-12-14 10:05:37 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 237, '2014-05-21 04:32:22 AM', '2021-01-14 04:04:05 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 9, '2019-03-23 02:04:46 PM', '2020-03-12 06:54:20 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 34, '2010-07-07 11:16:37 PM', '2017-04-07 01:56:39 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 146, '2011-03-31 09:36:19 PM', '2015-01-15 02:59:10 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 216, '2009-04-20 02:38:41 AM', '2018-04-01 07:49:59 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 77, '2017-03-13 02:01:59 PM', '2019-08-23 01:42:20 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 223, '2017-06-10 08:08:22 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 57, '2021-02-19 03:29:45 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 251, '2008-10-17 12:44:24 PM', '2018-09-29 07:29:11 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 214, '2016-08-09 11:41:13 PM', '2018-08-18 05:16:02 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 84, '2009-10-13 06:48:21 PM', '2017-09-15 08:06:00 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 183, '2014-12-14 09:27:45 AM', '2018-07-26 04:29:54 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 273, '2009-06-09 05:18:57 PM', '2020-09-04 10:50:28 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 45, '2008-11-30 08:59:30 AM', '2009-03-10 01:00:10 AM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 195, '2008-05-28 05:37:56 AM', '2013-05-31 08:56:19 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 153, '2009-01-19 08:15:21 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 148, '2011-09-26 10:03:32 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 157, '2009-01-25 05:30:26 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 110, '2017-10-23 06:32:59 AM', '2020-07-20 03:07:11 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 166, '2013-02-05 01:58:53 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 65, '2010-03-27 05:04:32 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 97, '2020-04-04 02:43:06 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 288, '2016-02-17 12:02:33 PM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 229, '2011-06-27 07:01:25 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 224, '2012-03-19 07:40:51 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 171, '2015-10-15 01:32:13 PM', '2017-12-05 06:54:45 PM');
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 117, '2014-02-08 10:02:45 AM', null);
INSERT INTO ppl.couriers_statuses( courier_id, "from", "to" ) VALUES ( 29, '2017-04-05 11:51:38 AM', '2019-07-16 05:02:35 AM');
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 0, 'dkb6see5', 2806559, 4193, 5922, 865);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 1, 'xmx1jwn5', 2295657, 2213, 6675, 544);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 2, 'btq8lav0', 3509532, 2201, 6674, 744);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 3, 'shc5yhf0', 2042369, 4304, 5718, 731);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 4, 'rmm1dfv4', 2428628, 2682, 3314, 724);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 5, 'ynk2dgz5', 2037737, 3981, 3099, 849);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 6, 'yhj8hbf6', 4315526, 4420, 5797, 639);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 7, 'hjh1dom0', 4775619, 2089, 6220, 880);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 8, 'jgu1nnj4', 2770527, 4434, 3605, 610);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 9, 'rer8scl3', 2151250, 4836, 6698, 960);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 10, 'qjx3ulb1', 4908460, 2458, 6055, 943);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 11, 'pyn6shc5', 2925034, 4731, 3014, 611);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 12, 'hng3qje3', 2444927, 4997, 5946, 942);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 13, 'oga7nqy8', 4829759, 3620, 6825, 720);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 14, 'uvl3hco2', 3775145, 4933, 6295, 696);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 15, 'pyq5ofz6', 3942834, 2475, 3755, 997);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 16, 'wvt2wvh5', 2018940, 3647, 4304, 941);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 17, 'dbv5xsq0', 3314164, 2281, 6006, 642);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 18, 'ovt3owg2', 3572046, 3330, 4122, 624);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 19, 'lob8hun4', 4851766, 3239, 3920, 797);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 20, 'wxm1ocq8', 3253183, 2859, 6230, 756);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 21, 'uab4hyj0', 2446271, 2508, 6037, 539);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 22, 'toy7itq6', 4313978, 3462, 6126, 520);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 23, 'exb3kkb6', 4540442, 4830, 6572, 842);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 24, 'olm4mlu3', 2108233, 4672, 5096, 725);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 25, 'onk3dbc6', 4302123, 3607, 3206, 677);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 26, 'kem9yex4', 3150075, 3715, 4387, 651);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 27, 'vcf4ivk6', 3173314, 2762, 4921, 563);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 28, 'mcy6wfo6', 4257143, 4072, 6626, 675);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 29, 'iad9pnf4', 2481920, 4884, 5282, 846);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 30, 'fwe7otw3', 2933014, 3001, 5231, 601);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 31, 'rlh4fyj8', 2607029, 2780, 5287, 517);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 32, 'bso0jcg4', 4628827, 3258, 6591, 597);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 33, 'xgq4xnc1', 4677276, 2376, 3858, 616);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 34, 'onr6vhe3', 4901709, 4244, 4293, 519);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 35, 'mxc5jxo8', 2202012, 3406, 3593, 842);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 36, 'reu6hsx0', 4199519, 2507, 5723, 792);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 37, 'dzy9juh4', 3336777, 3354, 6746, 917);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 38, 'sxl9xxt5', 4318199, 2849, 5247, 809);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 39, 'lss4qei5', 4571404, 3503, 4169, 825);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 40, 'epz2jnf3', 4848118, 3533, 6254, 637);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 41, 'duu5nli2', 4607222, 3495, 4342, 851);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 42, 'iae6vkq2', 4826223, 3006, 5888, 1000);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 43, 'gni4jbd3', 3619069, 2959, 5465, 738);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 44, 'bah3mpu1', 3596142, 4528, 5867, 546);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 45, 'yck7mbj5', 4240657, 2161, 3229, 929);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 46, 'vyl7ozx2', 2631973, 4699, 4801, 780);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 47, 'bjk7bnx6', 2684223, 4196, 5132, 747);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 48, 'ncw6uju3', 3964120, 3675, 5493, 918);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 49, 'qoi8pxv2', 2826238, 2656, 5756, 591);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 50, 'tnx6ghu3', 2346779, 2143, 6460, 514);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 51, 'dkh1egg9', 3732266, 2309, 5016, 592);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 52, 'nxw8xqz8', 4493662, 3671, 4994, 943);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 53, 'xpm3kce6', 4531148, 3756, 5921, 580);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 54, 'mqd1mlh4', 4476981, 2853, 6336, 972);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 55, 'rky7cqw6', 3309768, 4126, 4738, 790);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 56, 'ywt4txm8', 4708047, 4825, 3654, 504);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 57, 'dkt3qof8', 4516257, 2232, 5632, 787);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 58, 'bki3ims2', 3098020, 2776, 4525, 503);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 59, 'ouy5hol1', 3416083, 4547, 4820, 888);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 60, 'hlo7dbk1', 4914085, 3486, 6316, 648);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 61, 'csj6tdi6', 3329902, 2421, 3238, 822);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 62, 'nhs1yfw8', 3207747, 3912, 6349, 939);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 63, 'vxt2bxq6', 3534929, 3939, 4746, 797);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 64, 'gmh5xwg1', 2284115, 4020, 5055, 641);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 65, 'tow3ndk0', 4877101, 4255, 4217, 507);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 66, 'diz4bve1', 3618268, 2470, 5549, 667);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 67, 'blc6bsh5', 3816297, 3345, 5865, 885);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 68, 'byk8llw5', 2599408, 3188, 4502, 986);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 69, 'tkk0upl1', 4011715, 2448, 3996, 534);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 70, 'hyv2cma6', 3016085, 2022, 5947, 541);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 71, 'wzv5okh1', 2802421, 4670, 5707, 917);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 72, 'lop4wen6', 2884844, 4665, 6219, 994);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 73, 'bis4ypy4', 3405531, 2841, 3097, 887);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 74, 'dyy4his8', 4997103, 4227, 4796, 595);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 75, 'nia7nbt7', 2151068, 4882, 3066, 514);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 76, 'ntz1jnh5', 3919657, 2524, 3988, 531);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 77, 'hzf4avf3', 3110911, 4096, 3172, 556);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 78, 'cij4jni1', 4466045, 4519, 3593, 905);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 79, 'kib9dmv6', 3525257, 4621, 6134, 583);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 80, 'lcg5tsk4', 2270139, 3829, 3430, 904);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 81, 'bxn2iqy4', 4152615, 2196, 6920, 881);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 82, 'xxq3twu5', 2779107, 4689, 5703, 916);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 83, 'doa3rbd2', 4190565, 2420, 4964, 681);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 84, 'hqh3gvn2', 3057589, 2002, 6066, 560);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 85, 'mfs4nxi8', 2559589, 3350, 5533, 635);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 86, 'uds7fjq7', 3404154, 2573, 4948, 573);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 87, 'vbx1nua6', 4889521, 2061, 6750, 960);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 88, 'qwb3rek7', 3148439, 3388, 5757, 767);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 89, 'dft8sqy3', 4478972, 3058, 3990, 713);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 90, 'tmv3geo7', 4674557, 2041, 5158, 722);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 91, 'ndb1hhv7', 3247137, 3292, 5652, 755);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 92, 'xrp6rqp1', 3833348, 2395, 6380, 794);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 93, 'duc1uko4', 2402240, 4214, 3391, 985);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 94, 'ieq3ksh6', 3420749, 4153, 5692, 932);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 95, 'brw7lxl6', 2302460, 3416, 4340, 954);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 96, 'joj2kts2', 2348207, 2796, 3689, 777);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 97, 'kmk3zjh1', 4077401, 3207, 6501, 985);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 98, 'pft7hib6', 3877842, 4821, 6088, 669);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 99, 'qpx6dfx8', 3758088, 4902, 5937, 644);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 100, 'ufs1epq8', 2782366, 2158, 5483, 967);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 101, 'mhw6yfw6', 2381277, 4026, 5748, 745);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 102, 'gdk6wpu5', 2288175, 4412, 4216, 602);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 103, 'spe7abq0', 4192935, 4388, 4721, 979);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 104, 'ify7sce6', 4018046, 4008, 4521, 861);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 105, 'gio6vrs3', 2282445, 4410, 4166, 595);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 106, 'xxf8ote3', 3044385, 2596, 6729, 740);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 107, 'xbj2sxp8', 4793062, 3014, 5736, 977);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 108, 'ngb3mpv0', 4349762, 4178, 4087, 890);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 109, 'axx2pfh8', 4038008, 3065, 5103, 780);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 110, 'efr2vig5', 2051634, 3341, 6075, 617);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 111, 'dew7gax1', 2121258, 2190, 5332, 843);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 112, 'jee3due8', 3343722, 2834, 6630, 817);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 113, 'xev2rou9', 4936404, 3929, 6009, 687);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 114, 'ymk3rzv1', 3226864, 4226, 4985, 824);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 115, 'eqv3twp2', 2068087, 2412, 6752, 549);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 116, 'krh3kor2', 3314558, 4986, 3652, 798);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 117, 'pgo7bgc8', 4223579, 3420, 5180, 880);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 118, 'jau3sya8', 4698463, 4264, 3098, 839);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 119, 'kfc8qyq4', 3405450, 4827, 6984, 703);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 120, 'vxv9glw1', 4520373, 4747, 5782, 726);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 121, 'zkg1zpt8', 4331346, 3445, 6102, 517);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 122, 'lld6kiu0', 3321494, 4181, 5257, 866);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 123, 'uqw7ste8', 3298304, 3721, 5422, 806);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 124, 'fsw6bet8', 3806959, 3363, 5948, 897);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 125, 'kbm6ysr7', 3164428, 4886, 5849, 531);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 126, 'jhn7lnb7', 2581623, 2520, 3034, 688);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 127, 'fyr6uzc4', 3720945, 4099, 3266, 670);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 128, 'crj7kif5', 3968194, 4936, 3612, 894);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 129, 'xyg9vzn1', 2996628, 3042, 5984, 713);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 130, 'ays0krv7', 3825168, 2121, 4135, 966);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 131, 'pzy3jfw3', 2971407, 3960, 5154, 758);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 132, 'iws5pqz4', 2531999, 2961, 6233, 653);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 133, 'cbw7bmt6', 4476768, 3373, 6498, 579);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 134, 'jsi5ykt2', 2023180, 4436, 6639, 865);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 135, 'fvp6rfo1', 4380775, 2782, 5127, 793);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 136, 'elr5eds2', 4029862, 2111, 5417, 659);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 137, 'qas3neu2', 4351479, 2610, 3553, 563);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 138, 'uke1rlu2', 4954227, 3707, 4348, 945);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 139, 'dfk6doy4', 2873834, 4133, 5890, 862);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 140, 'trj3rqm2', 4062830, 2368, 3697, 992);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 141, 'qqk7ipi3', 4774637, 4079, 6132, 701);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 142, 'ure1xic2', 3773566, 3408, 6084, 916);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 143, 'tft5ngj7', 4253272, 4142, 3156, 752);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 144, 'elm4vux5', 4638001, 2352, 3401, 548);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 145, 'xzc4bsc4', 3492153, 3780, 3186, 569);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 146, 'yjb7del4', 3425646, 3356, 3353, 508);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 147, 'fdr7ztd8', 4951731, 2913, 5980, 517);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 148, 'gmb5wwr1', 3316925, 2752, 5799, 695);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 149, 'qxg4wbq5', 2766052, 2418, 3453, 754);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 150, 'ycs5ebn6', 4252384, 2695, 3577, 563);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 151, 'ebd5zgw9', 3524311, 4738, 3070, 719);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 152, 'xga8bhy4', 3690958, 3030, 6516, 893);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 153, 'eei8pbr7', 4633209, 3287, 6848, 634);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 154, 'ggp1dhr4', 3451418, 4411, 3964, 764);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 155, 'qsh2pbq3', 4338729, 4227, 4411, 937);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 156, 'xco5mzj7', 4578499, 3994, 4140, 905);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 157, 'bed1eqi1', 2981789, 3456, 5191, 680);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 158, 'kck7egc1', 2746560, 4264, 6092, 888);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 159, 'lxq3ymo1', 4761121, 2189, 6922, 982);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 160, 'lig2gjy7', 3125172, 4567, 3033, 619);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 161, 'pnx8eft8', 3972427, 2352, 6966, 883);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 162, 'kev8wdp8', 2746909, 3929, 3407, 997);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 163, 'nvs3dsm0', 3632562, 4312, 4381, 830);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 164, 'cvo4rir9', 4680396, 2957, 4524, 797);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 165, 'lrj4uqh1', 3531319, 4344, 3964, 766);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 166, 'mxg0qfn1', 4991608, 3769, 5099, 556);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 167, 'ssm7zgc6', 4984715, 3333, 5561, 540);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 168, 'kww7elv6', 4922417, 2564, 6998, 581);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 169, 'fnb3bsj6', 4998903, 3479, 6828, 725);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 170, 'uqk4gkh7', 3603980, 2062, 6188, 676);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 171, 'xyr8pbe4', 2752552, 2530, 4258, 871);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 172, 'hci6mrd3', 2208762, 2305, 6834, 565);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 173, 'vsx6xty4', 4530446, 3005, 3906, 702);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 174, 'zqa8brf6', 3811792, 2511, 3168, 908);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 175, 'xhu9tpe2', 4707948, 3973, 4834, 509);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 176, 'usi2men2', 4540209, 3595, 4692, 901);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 177, 'wxl4iik1', 3513851, 2772, 3269, 915);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 178, 'bnu6yfb7', 2329639, 3746, 3170, 867);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 179, 'jdx5oux3', 4959999, 3023, 6919, 654);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 180, 'gfx7xds6', 3843748, 3010, 3371, 522);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 181, 'bgj4rqd2', 4095156, 4048, 5355, 985);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 182, 'qxj0dne3', 3744973, 2967, 6368, 873);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 183, 'ckz7sfs7', 2146242, 2137, 5071, 806);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 184, 'lxv6iks8', 3503638, 3654, 6254, 933);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 185, 'fkm4lsv1', 4883647, 4650, 3423, 975);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 186, 'ime5ktk9', 2601024, 2155, 4249, 782);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 187, 'jlk3njq5', 3873510, 2001, 3500, 875);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 188, 'gfg4suu9', 4199552, 2454, 5295, 729);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 189, 'hny7zab3', 2046234, 2693, 4852, 855);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 190, 'mvq7lqc7', 2827914, 3225, 6320, 757);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 191, 'ajq3pwx5', 3058019, 2537, 6349, 684);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 192, 'kqk4tyh5', 2146934, 4078, 4602, 571);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 193, 'vpi5tjn0', 3294636, 2582, 4285, 973);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 194, 'beq8xcd8', 4537476, 3138, 5021, 865);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 195, 'yfi6nfz3', 2561284, 4228, 4564, 660);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 196, 'opz2woh9', 4777071, 2787, 3806, 695);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 197, 'ocq8ucl6', 3719156, 3157, 3719, 569);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 198, 'rrc2xro4', 2967829, 3420, 4814, 625);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 199, 'vzm6wuf5', 3921859, 3657, 5067, 855);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 200, 'pzy6fjz7', 4743025, 2438, 4789, 754);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 201, 'eru9bij9', 2029249, 2210, 4872, 774);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 202, 'isc3pwf9', 4540509, 3610, 4819, 919);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 203, 'fkb5puk4', 4042400, 2010, 4699, 554);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 204, 'efs8czq4', 4892438, 4929, 5714, 809);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 205, 'lle4tqq5', 3523799, 2791, 3488, 947);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 206, 'trv5ivt8', 2575956, 2005, 6878, 582);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 207, 'nfo5juh3', 4407419, 4660, 4332, 511);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 208, 'kpg1hop3', 2509374, 4693, 3938, 651);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 209, 'tem7bxg8', 3032943, 4981, 5736, 511);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 210, 'pqi1qhx6', 4202432, 2606, 6531, 910);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 211, 'upg4lod4', 4779133, 3756, 3579, 828);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 212, 'dvw8hyu8', 4694732, 3382, 4022, 807);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 213, 'lxy1upl6', 2148505, 2931, 3435, 734);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 214, 'juv4wrv7', 2388933, 2449, 5184, 913);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 215, 'iye8rnc9', 2347154, 4046, 5685, 735);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 216, 'bsx1zvc1', 4228390, 3630, 6897, 630);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 217, 'wvs8xse2', 4291515, 3164, 3585, 649);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 218, 'cob6vrx2', 4834426, 4459, 5571, 704);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 219, 'ntv7uge3', 3992327, 4900, 3482, 876);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 220, 'gfv4inh8', 2636152, 3743, 5189, 670);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 221, 'mii5pyh1', 2553021, 3226, 4494, 983);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 222, 'snb2rts3', 3653763, 3707, 3684, 646);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 223, 'jww2xca7', 4665849, 4738, 6674, 860);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 224, 'fro4nmi8', 3470669, 4369, 3753, 734);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 225, 'dit7ydg5', 3788304, 4861, 5809, 626);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 226, 'ibw5gjf0', 2414843, 4330, 4403, 633);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 227, 'tyd8fel2', 4881856, 4760, 4295, 602);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 228, 'noz1iri3', 2007910, 4578, 3680, 516);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 229, 'qwk2bme3', 4144848, 2940, 4818, 741);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 230, 'bri2jre8', 4102149, 2545, 5371, 737);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 231, 'gfs7ast9', 2975019, 2036, 5791, 518);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 232, 'nwu3pqm9', 4659376, 4452, 4342, 520);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 233, 'ubp2vds6', 2060819, 3404, 6638, 699);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 234, 'rjo9rmc8', 3008512, 4035, 6006, 883);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 235, 'dgt5eot8', 4084212, 2640, 6017, 831);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 236, 'qop6fer5', 4405155, 3055, 3478, 637);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 237, 'kvd7vmt2', 4783534, 3460, 5239, 987);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 238, 'hfp9oow2', 2389968, 3556, 6046, 705);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 239, 'mkz6jtm5', 2789192, 3629, 5297, 690);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 240, 'gmf5ccu4', 4464019, 4811, 5913, 743);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 241, 'pve2miy1', 3626330, 4235, 3726, 734);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 242, 'bfq1gti4', 2957842, 4911, 4675, 854);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 243, 'xgt3asv4', 3949244, 3223, 5777, 876);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 244, 'qdb6lgw5', 3234180, 3493, 3168, 975);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 245, 'nlk3drm3', 4507440, 4024, 3912, 869);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 246, 'mus4jcl3', 2927688, 3476, 4996, 650);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 247, 'cdj6iit1', 2571111, 2578, 3432, 746);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 248, 'ngi9oxt1', 4261920, 2622, 3053, 987);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 249, 'cyi3hln0', 4795941, 4160, 6917, 816);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 250, 'zqu3ref3', 3396488, 3154, 5540, 743);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 251, 'sgn5joi1', 3468076, 2074, 5376, 554);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 252, 'izs6jjb6', 4625223, 2720, 6260, 965);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 253, 'goz8vvj2', 4127509, 4401, 4394, 929);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 254, 'jxt6zbn2', 3277490, 4117, 4456, 748);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 255, 'yvc6tdo5', 4062880, 4975, 4550, 533);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 256, 'efw0snb1', 2655655, 4836, 6057, 964);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 257, 'dqu1vjh1', 2646690, 4580, 3952, 657);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 258, 'uqw4hxl4', 4886373, 4870, 5201, 734);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 259, 'uqa8mmx3', 3934250, 3811, 6382, 547);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 260, 'vtb4see5', 3364116, 4910, 3370, 759);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 261, 'yms4htg9', 3082573, 2026, 6426, 613);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 262, 'ykq4hkq3', 2542877, 4018, 6763, 897);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 263, 'sqs7qem8', 2610103, 4701, 4675, 761);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 264, 'coq2deo2', 3284739, 2910, 6841, 846);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 265, 'pyl3kqg9', 2171195, 3095, 4899, 948);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 266, 'odq6caf3', 2228842, 3793, 6866, 820);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 267, 'vzn6beg1', 4670105, 3248, 6781, 626);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 268, 'elp4ibx5', 2706077, 2276, 5917, 528);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 269, 'vuh3vvq7', 3200724, 4836, 5692, 509);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 270, 'xiq2dum7', 2426572, 3654, 3077, 856);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 271, 'xel1lsn9', 4436023, 2470, 6999, 984);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 272, 'smm1kvo7', 3419850, 3013, 4571, 602);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 273, 'tsw2lmu4', 3874382, 4569, 4049, 872);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 274, 'yne7mfh5', 4750731, 3381, 4386, 862);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 275, 'foa7nhz0', 2400445, 4567, 6204, 895);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 276, 'tme8mdu8', 4184932, 2799, 3959, 617);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 277, 'fdl3fzz2', 3261287, 3800, 5806, 861);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 278, 'htb8dmp8', 4882454, 2795, 4575, 810);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 279, 'tev4svk4', 3072711, 2087, 6845, 674);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 280, 'vtm8eeo5', 3077857, 2743, 4128, 944);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 281, 'wzz8fmq0', 4336834, 3562, 3073, 659);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 282, 'sro4wsb5', 4616133, 3766, 6573, 677);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 283, 'tjw3rhb8', 4105502, 4339, 3751, 835);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 284, 'xgo1oud8', 3781031, 3870, 5830, 962);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 285, 'ewc5ejn4', 4501919, 2892, 6815, 542);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 286, 'wnj4cbw0', 3537344, 2343, 3994, 938);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 287, 'okf0rjg2', 2406329, 4611, 6600, 953);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 288, 'uqv3gyk3', 4645953, 4116, 5568, 615);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 289, 'sfq1bit6', 2514276, 4718, 4169, 685);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 290, 'dqe1cbk4', 3964636, 3762, 6194, 520);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 291, 'fqd6jjg7', 2435255, 2939, 5414, 531);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 292, 'mcx6nud6', 3061153, 3515, 6196, 829);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 293, 'azc7yfi6', 4465368, 4002, 3451, 801);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 294, 'ubh0mge4', 4308401, 2754, 4422, 688);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 295, 'hli1tpy6', 2043498, 3857, 6142, 709);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 296, 'fsc3hdk7', 2253153, 3376, 3692, 858);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 297, 'dps3hqo6', 3792741, 4507, 3005, 717);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 298, 'pjp8yow7', 3926827, 2898, 3034, 975);
INSERT INTO ppl.couriers_trucks( id, truck_number, max_weight, height, "length", width ) VALUES ( 299, 'ryk7qwp5', 3017111, 4669, 3135, 631);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 0, 'dKBQ6E', 'lomza', 'Koziarowka', 365, 75746, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 1, 'eoxm8E', 'Ostrzeszow', 'Gorka Narodowa', 459, 17943, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 2, 'JwNp0T', 'Proszowice', 'Obopolna', 459, 54000, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 3, 'QWla8b', 'Bierutow', 'Franciszka Kowalskiego', 340, 51564, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 4, 'sHCp9H', 'Braniewo', 'Nawojowska', 40, 50373, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 5, 'fARM4d', 'lapy', 'Bibicka', 13, 72793, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 6, 'dFVK9N', 'Gniew', 'Ludwika Pasteura', 349, 34998, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 7, 'kHdg9p', 'Czarne', 'Nad zrodlem', 402, 78395, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 8, 'yHJW3B', 'Elk', 'Porzeczkowa', 76, 29731, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 9, 'fqhj2D', 'Nowa_Sol', 'Pod Fortem', 462, 92836, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 10, 'DOma3G', 'Sobotka', 'Wroclawska', 382, 89744, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 11, 'udnn3L', 'Gubin', 'Stanislawa Konarskiego', 2, 29979, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 12, 'ReRx7c', 'Walcz', 'Cichy Kacik', 368, 89548, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 13, 'LiQj8i', 'Dzialdowo', 'Droznicka', 478, 49551, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 14, 'ulbd5y', 'Gniew', 'Gorna', 412, 45358, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 15, 'nQsH1p', 'Klodawa', 'Ludomira Benedyktowicza', 95, 99524, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 16, 'HnGH6J', 'Zielona_Gora', 'Kamedulska', 163, 89334, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 17, 'ejOg0v', 'Chelmno', 'Daleka', 376, 35483, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 18, 'nQYW7v', 'swinoujscie', 'Hoza', 140, 32304, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 19, 'LIhc5h', 'Wrzesnia', 'Tadeusza Makowskiego', 115, 63420, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 20, 'PyQo5f', 'Olesnica', 'Gleboka', 404, 56065, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 21, 'zSWv7f', 'Olkusz', 'Misjonarska', 379, 16948, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 22, 'WVHO1B', 'Nowy_Tomysl', 'os.Krowodrza Gorka', 390, 13614, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 23, 'voxs6a', 'Jarocin', 'Kiejstuta zemaitisa', 446, 71475, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 24, 'OvTj5w', 'Minsk_Mazowiecki', 'Puszczykow', 262, 50565, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 25, 'GgLO0w', 'Brzesko', 'Astronomow', 26, 41909, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 26, 'hUnK8x', 'Wielun', 'Gaik', 174, 37165, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 27, 'MCoC6V', 'Golub-Dobrzyn', 'Orna', 240, 21288, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 28, 'uABL2y', 'sroda_Wielkopolska', 'Krancowa', 453, 41476, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 29, 'jbTo9u', 'Miedzychod', 'Na Nowinach', 285, 72307, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 30, 'ITQQ2x', 'Sopot', 'Stanislawa Ciechanowskiego', 279, 28226, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 31, 'bJkk0S', 'swinoujscie', 'Obozna', 286, 13069, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 32, 'OLml4L', 'Kudowa-Zdroj', 'Ludwika Wegierskiego', 448, 27396, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 33, 'UiON4I', 'Grudziadz', 'Astronautow', 108, 30909, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 34, 'dbCR4e', 'lapy', 'Kornela Ujejskiego', 162, 13459, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 35, 'MzYE8L', 'Czarnkow', 'Wladyslawa Podkowinskiego', 74, 71563, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 36, 'VcFK3v', 'Siedlce', 'Grzegorza Korzeniaka', 340, 62485, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 37, 'krMC9r', 'Lubsko', 'Jadwigi Majowny', 468, 85009, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 38, 'wFoq3A', 'Rumia', 'Kmieca', 281, 65576, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 39, 'dZpN2M', 'sroda_slaska', 'Franciszka Bielaka', 146, 68551, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 40, 'FWet5t', 'Nasielsk', 'Zakliki z Mydlnik', 406, 34645, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 41, 'WjRL2K', 'Stronie_slaskie', 'Poreba', 168, 73250, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 42, 'FyjW0S', 'Zdzieszowice', 'Agrestowa', 361, 99928, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 43, 'oBjc2M', 'Ostrowiec_swietokrzyski', 'Czeslawa Niemena', 308, 52810, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 44, 'xGqM8n', 'Szydlowiec', 'Jasnogorska', 358, 18245, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 45, 'cEon6q', 'Poddebice', 'Skladowa', 29, 87211, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 46, 'Vhej4X', 'Gorlice', 'Kaszubska', 225, 60444, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 47, 'coJx5x', 'Polkowice', 'Podchorazych', 266, 54388, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 48, 'rEUR3s', 'Plock', 'Witolda Budryka', 312, 85271, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 49, 'Xbdz9Y', 'Katowice', 'Kopalina', 344, 26464, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 50, 'JUhm6x', 'Kudowa-Zdroj', 'swietokrzyska', 432, 12547, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 51, 'LZxX7O', 'Przemysl', 'Stefana Jaracza', 252, 26593, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 52, 'LSsm6E', 'swinoujscie', 'Jadwigi z lobzowa', 249, 89803, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 53, 'InEP9g', 'Lebork', 'al.Konarowa', 365, 24320, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 54, 'jnFJ1U', 'Sulecin', 'Redzina', 417, 94946, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 55, 'uPnl3H', 'Strzelce_Krajenskie', 'Karola Szymanowskiego', 217, 62176, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 56, 'iAeS7K', 'Jastrzebie-Zdroj', 'Szaserow', 82, 10706, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 57, 'QgGn3m', 'Pyrzyce', 'al.Jerzego Waszyngtona', 329, 61662, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 58, 'jbdJ0a', 'Cieszyn', 'Jozefa Wybickiego', 191, 10529, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 59, 'himp7C', 'Bialogard', 'Syreny', 228, 79847, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 60, 'yckv4B', 'Trzebinia', 'Olszanicka', 414, 36607, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 61, 'JOvY4t', 'Trzebinia', 'Akademicka', 30, 67894, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 62, 'ozxf0j', 'Bierun_Ledziny', 'Emaus', 418, 88946, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 63, 'kSbn8s', 'Dlugoleka', 'Zaklucze', 218, 63503, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 64, 'ncwq7j', 'Choszczno', 'Orna', 257, 35357, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 65, 'UiQO3V', 'Bielsko-Biala', 'os.Srebrne Uroczysko', 152, 11340, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 66, 'Pxvg7N', 'Bierun_Ledziny', 'Zakret', 319, 40010, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 67, 'xqgH7J', 'Wielun', 'Mieczyslawa Karlowicza', 358, 79299, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 68, 'DKHc2G', 'Krasnik', 'Mrowczana', 188, 97416, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 69, 'Gznx8v', 'Belzyce', 'Olkuska', 125, 16198, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 70, 'xQZY8p', 'swidnik', 'Daniela Chodowieckiego', 368, 17434, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 71, 'mIKc2s', 'Kolobrzeg', 'Baltycka', 338, 85069, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 72, 'MqDd4l', 'lomianki', 'Koralowa', 402, 98923, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 73, 'hlRK9u', 'Minsk_Mazowiecki', 'Tkacka', 13, 79582, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 74, 'CQwq9w', 'Raciborz', 'Rzepichy', 225, 27138, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 75, 'TKtX4W', 'Pleszew', 'Filtrowa', 9, 12494, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 76, 'DKtJ6o', 'Klodawa', 'Biala', 124, 15546, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 77, 'fXBK3J', 'Jaroslaw', 'Borowczana', 22, 20062, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 78, 'ImSH5U', 'Goldap', 'Jozefa Rostafinskiego', 74, 82892, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 79, 'yPHO4e', 'Imielin', 'Emilii Plater', 391, 24884, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 80, 'HlOS1b', 'Zlotow', 'Podluzna', 54, 82644, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 81, 'Kccs3s', 'Znin', 'Zakamycze', 489, 78653, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 82, 'tdiq5H', 'Rawa_Mazowiecka', 'Biale Wzgorze', 338, 84838, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 83, 'sdYf8v', 'Bolkow', 'Mieczyslawa Maleckiego', 245, 42497, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 84, 'vXtF0x', 'Ostrow_Wielkopolski', 'Jana Buszka', 383, 20782, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 85, 'QsGm3p', 'Brzeg_Dolny', 'Zaczarowane Kolo', 317, 34291, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 86, 'Xwgb7o', 'Chelmza', 'Bibicka', 244, 23159, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 87, 'Wjnd3A', 'Brzeg_Dolny', 'Porzecze', 468, 92871, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 88, 'DIzL0V', 'Pruszkow', 'Berberysowa', 344, 58118, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 89, 'EDbL1R', 'Zdzieszowice', 'Amazonek', 124, 48379, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 90, 'BsHP0y', 'Poznan', 'Adama Staszczyka', 270, 50017, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 91, 'kXLL8p', 'Zabrze', 'Skladowa', 331, 55855, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 92, 'tkKB7P', 'Tarnobrzeg', 'Brzegowa', 422, 62893, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 93, 'LeHy7G', 'Goldap', 'Karola Popiela', 49, 97279, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 94, 'CMAR8Z', 'Krasnystaw', 'Wiedenska', 336, 87776, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 95, 'vOOK3c', 'Luban', 'Turystyczna', 168, 91698, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 96, 'loPL8E', 'Pyrzyce', 'Adama Chmiela', 86, 59833, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 97, 'nQbi7m', 'Grodzisk_Mazowiecki', 'Gnieznienska', 437, 97297, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 98, 'yPyk1Y', 'Naklo_nad_Notecia', 'Kaczorowka', 386, 40448, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 99, 'yMHi7w', 'Pruszcz_Gdanski', 'Zygmunta Starego', 367, 35873, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 100, 'NiAt5B', 'Wolomin', 'Skotnica', 310, 94080, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 101, 'ttnt9e', 'Zelow', 'Wincentego Danka', 343, 54050, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 102, 'JNHO3Z', 'Ilawa', 'Maczna', 152, 28363, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 103, 'fLAv2J', 'Olecko', 'Torunska', 215, 96140, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 104, 'cIJl3N', 'Reda', 'Redzina', 190, 75024, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 105, 'iEKi0y', 'Zbaszyn', 'Mlaskotow', 146, 27010, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 106, 'DmVR4C', 'Proszowice', 'Drozyna', 466, 53114, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 107, 'gots4M', 'Sierpc', 'Nad Zalewem', 342, 95774, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 108, 'BXnf3Q', 'Rawicz', 'Wernyhory', 136, 80282, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 109, 'YmXX6i', 'Skoczow', 'Wojciecha Halczyna', 263, 60398, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 110, 'twUP1o', 'Zakopane', 'Stanislawa Rokosza', 384, 30984, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 111, 'AiRb1f', 'Orzesze', 'Marii Jaremy', 291, 71821, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 112, 'hQhj2V', 'Plonsk', 'Aleksandra Prystora', 453, 67011, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 113, 'NemF6k', 'Ropczyce', 'Wiosenna', 376, 43672, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 114, 'NXIX7d', 'Siechnice', 'Zaborska', 248, 68251, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 115, 'suFj6t', 'Debica', 'Eugeniusza Romera', 469, 18840, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 116, 'vBxD5u', 'Kowary', 'Juliana Tokarskiego', 82, 63696, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 117, 'Arqw0j', 'Tarnow', 'Zygmunta Starego', 272, 78346, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 118, 'ReKt1f', 'Pszczyna', 'Gabrieli Zapolskiej', 13, 71060, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 119, 'txsq9j', 'Pinczow', 'Daniela Chodowieckiego', 498, 46619, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 120, 'TmVI2E', 'Zagan', 'Bibicka', 348, 50631, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 121, 'oUND0d', 'Rawicz', 'Malownicza', 387, 13082, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 122, 'HHvt8r', 'Nowy_Dwor_Gdanski', 'Stelmachow', 282, 75858, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 123, 'PSRQ6e', 'Sanok', 'Przyjemna', 303, 65058, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 124, 'duCD7k', 'Sosnowiec', 'Jana Stanislawskiego', 368, 81409, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 125, 'OlIe6i', 'Pabianice', 'Tadeusza Ochlewskiego', 356, 15602, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 126, 'kshP0R', 'Kety', 'Kopalina', 5, 43793, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 127, 'wTLx4R', 'Jelenia_Gora', 'Niezapominajek', 34, 40599, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 128, 'joJG4t', 'Debica', 'Przepiorcza', 77, 80909, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 129, 'shkm3i', 'Olecko', 'Mieczyslawa Karlowicza', 373, 48304, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 130, 'ZjHe6F', 'Konstancin-Jeziorna', 'inneKopiec Kosciuszki', 142, 93927, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 131, 'tShi0q', 'Miedzyrzecz', 'Zygmunta Myslakowskiego', 269, 56396, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 132, 'qPXr1F', 'Plonsk', 'Poniedzialkowy Dol', 404, 37518, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 133, 'XxUf7D', 'Lubawka', 'Jozefa Friedleina', 437, 24209, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 134, 'ePqx4h', 'Gniezno', 'Dziewanny', 454, 75638, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 135, 'wPyf8R', 'Grudziadz', 'Jaskolcza', 266, 62748, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 136, 'gdKs8p', 'Bierutow', 'Mlodej Polski', 302, 38600, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 137, 'uNSP1U', 'Rawicz', 'Nawigacyjna', 70, 21279, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 138, 'ABqb3F', 'Strzelce_Krajenskie', 'Piotra Kluzeka', 169, 90154, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 139, 'yUSC1R', 'Skawina', 'Jerzego Samuela Bandtkiego', 361, 75222, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 140, 'gIoS8r', 'Limanowa', 'Wladyslawa lokietka', 88, 98619, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 141, 'sjXX2v', 'Tuszyn', 'Waleczna', 391, 46096, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 142, 'oTeh8b', 'Gniew', 'dr. Twardego', 385, 84819, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 143, 'jGsx5X', 'Bydgoszcz', 'Ksiecia Jozefa', 20, 55372, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 144, 'nGBI4P', 'Nowy_Sacz', 'Wladyslawa Syrokomli', 51, 18722, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 145, 'VaAX8G', 'Andrychow', 'Pod Szancami', 24, 22352, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 146, 'pFHW1f', 'Tomaszow_Mazowiecki', 'Warmijska', 45, 11387, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 147, 'RhvI2n', 'Belzyce', 'Nad Zalewem', 372, 12994, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 148, 'DewS2A', 'swiecie', 'Na Wyrebe', 350, 45060, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 149, 'xcJe2j', 'sroda_slaska', 'Eugeniusza Romera', 57, 55709, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 150, 'duEv8E', 'Polkowice', 'Owsiana', 72, 21400, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 151, 'VFRo7Y', 'Radom', 'Boleslawa Komorowskiego', 9, 49447, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 152, 'YmkJ6z', 'Stalowa_Wola', 'Wladyslawa lokietka', 439, 80739, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 153, 'VcEQ8H', 'Siewierz', 'Boleslawa Czerwienskiego', 481, 34185, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 154, 'TwPh4r', 'Lubawka', 'Zbrojow', 121, 57567, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 155, 'hIKo6f', 'Glogow', 'Porzecze', 177, 88736, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 156, 'pGOs0g', 'Krzeszowice', 'Kazimierza Puzaka', 143, 82817, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 157, 'CXjA7j', 'Trzebnica', 'Zygmunta Wyrobka', 274, 42428, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 158, 'SyaX4F', 'Nowa_Sol', 'Jozefa Rostafinskiego', 386, 79909, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 159, 'CWQY6l', 'Szklarska_Poreba', 'Ludwika Muzyczki', 490, 96758, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 160, 'vxvY2L', 'Sosnowiec', 'Bodziszkowa', 5, 31499, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 161, 'wDzk2C', 'Kobylka', 'prof. Stefana Myczkowskiego', 495, 78981, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 162, 'zpTv4l', 'Zary', 'Gnieznienska', 51, 99428, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 163, 'dQki7a', 'Nisko', 'Justowska', 173, 69418, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 164, 'uQwT7t', 'Sochaczew', 'Kiejstuta zemaitisa', 191, 63405, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 165, 'ewfS8q', 'Zychlin', 'Gorka Narodowa', 121, 57966, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 166, 'BeTW4b', 'Nowa_Deba', 'Halki', 262, 20052, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 167, 'Mrys6T', 'Nasielsk', 'Zimorodkow', 320, 17149, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 168, 'jHns4n', 'Jedrzejow', 'Margaretek', 499, 24567, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 169, 'buFY6P', 'Ustrzyki_Dolne', 'Orlich Gniazd', 478, 50477, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 170, 'UZcl1R', 'Gdynia', 'Witkowicka', 398, 41704, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 171, 'jUkI2N', 'Bytow', 'Jacka Malczewskiego', 157, 76778, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 172, 'Xygy8Z', 'Pyrzyce', 'Edmunda Biernackiego', 479, 21686, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 173, 'NdAy6b', 'Wyszkow', 'Podchorazych', 114, 46436, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 174, 'krVt5Z', 'Lezajsk', 'Zakliki z Mydlnik', 21, 83476, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 175, 'YIjf8K', 'Sosnowiec', 'Gryczana', 229, 11687, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 176, 'IwsN6Q', 'Koluszki', 'Sarnie Uroczysko', 212, 82108, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 177, 'ZKCB8s', 'Oborniki', 'Kopalina', 34, 84637, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 178, 'BMtq3S', 'Miedzychod', 'Brazownicza', 22, 76098, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 179, 'iPYK7e', 'Ostrzeszow', 'lukasza Gornickiego', 489, 37669, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 180, 'FVPs6F', 'Mikolow', 'inneLas Wolski', 47, 13962, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 181, 'OdEl6N', 'Gizycko', 'Gzymsikow', 294, 97293, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 182, 'edsF6a', 'Nowy_Sacz', 'Strzelnica', 421, 77144, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 183, 'ShnE7G', 'Pszczyna', 'Sosnowiecka', 259, 65088, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 184, 'UKEc6l', 'Legnica', 'Orla', 406, 87921, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 185, 'UfdF4r', 'Lubon', 'Jesionowa', 53, 95513, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 186, 'dOYL7R', 'Zdunska_Wola', 'Vlastimila Hofmana', 156, 60793, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 187, 'jhRQ4f', 'Strzelce_Krajenskie', 'Zimorodkow', 63, 77501, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 188, 'QqkT3P', 'Sosnowiec', 'Soltysa Dytmara', 287, 51240, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 189, 'IJur1d', 'Radlin', 'al.Kijowska', 231, 73836, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 190, 'Xicf7f', 'Zgorzelec', 'Przepiorcza', 415, 56284, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 191, 'tOnG3T', 'Wodzislaw_slaski', 'Droznicka', 418, 43198, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 192, 'ELML8U', 'Zabrze', 'Poziomkowa', 200, 22774, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 193, 'Xnxz1K', 'Skarszewy', 'Kadrowki', 161, 95191, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 194, 'BSCk9J', 'Szczecinek', 'Jodlowa', 253, 75733, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 195, 'bude4L', 'Klodzko', 'Chabrowa', 196, 38853, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 196, 'FDRU9t', 'Krzeszowice', 'Na Polankach', 101, 45051, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 197, 'DxGM0O', 'Lezajsk', 'Gradowa', 90, 22473, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 198, 'wWrd6x', 'lomza', 'dr. Tadeusza Kudlinskiego', 227, 32446, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 199, 'GkWb6o', 'Trzebnica', 'Ryszarda Berwinskiego', 258, 73860, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 200, 'ycSO2B', 'Oswiecim', 'Bazancia', 224, 55667, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 201, 'nreB1o', 'Kudowa-Zdroj', 'Wewnetrzna', 234, 59295, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 202, 'ZGwY8G', 'Gora_Kalwaria', 'Kolowa', 227, 85454, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 203, 'AVbh9l', 'Sulechow', 'Krakusow', 212, 19803, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 204, 'eeiw5B', 'Brzeg_Dolny', 'Urodzajna', 339, 65693, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 205, 'ruGg5D', 'Hajnowka', 'Wapiennik', 61, 90437, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 206, 'dhrk6S', 'swietochlowice', 'Konwisarzy', 484, 24671, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 207, 'hFpB6i', 'Piensk', 'Wapiennik', 167, 11998, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 208, 'xCOo4z', 'Zielona_Gora', 'Dziewanny', 118, 37172, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 209, 'JVBE1C', 'Goldap', 'Pod Strzecha', 342, 11972, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 210, 'EqIC4c', 'Pobiedziska', 'Adama Chmiela', 441, 83712, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 211, 'kseG1D', 'Debno', 'Glogowiec', 73, 69084, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 212, 'lxqH9M', 'Wielun', 'Nad zrodlem', 128, 65307, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 213, 'oEli2g', 'Szklarska_Poreba', 'Skalna', 55, 52162, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 214, 'gjyV5N', 'Wagrowiec', 'Starowolska', 273, 84268, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 215, 'XWef7W', 'Wasilkow', 'al.Modrzewiowa', 335, 52219, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 216, 'keVW8d', 'Prabuty', 'Jozefa Mackiewicza', 487, 33450, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 217, 'Pwnv7J', 'Torun', 'Piotra Stachiewicza', 73, 36817, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 218, 'dsma1V', 'Wladyslawowo', 'Stanislawa Kasznicy', 321, 46668, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 219, 'omRi6Y', 'Duszniki-Zdroj', 'Gospodarska', 61, 77600, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 220, 'LRJL7Q', 'Chodziez', 'Zefirowa', 274, 40641, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 221, 'hCmx2a', 'Strzyzow', 'Smetna', 187, 96992, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 222, 'QFnD7s', 'Wejherowo', 'Na Zielonki', 86, 36227, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 223, 'muZg1r', 'Piensk', 'Orla', 459, 74768, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 224, 'kwWt1l', 'Glowno', 'Czeladnicza', 94, 52112, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 225, 'VQFN0J', 'Zmigrod', 'Bazancia', 351, 32681, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 226, 'BsjS7Q', 'Siemianowice_slaskie', 'Obopolna', 175, 33893, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 227, 'KlGk2v', 'Torun', 'Morelowa', 162, 28394, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 228, 'XyRv6b', 'Kartuzy', 'Gajowka', 85, 12902, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 229, 'EKHc3q', 'Miedzychod', 'Nasza', 227, 53441, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 230, 'Mrdk8S', 'lobez', 'Jarzynowa', 296, 52743, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 231, 'XQXt9M', 'Lubsko', 'Nad zrodlem', 349, 13151, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 232, 'zqaW0R', 'Terespol', 'Jasnogorska', 168, 13535, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 233, 'fRXH7Y', 'Strzelin', 'Zielinska', 454, 45798, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 234, 'Tpee7s', 'Rabka-Zdroj', 'Lubelska', 375, 78938, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 235, 'igMe5h', 'Brzeg_Dolny', 'Piotra Wysockiego', 377, 69625, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 236, 'WXlK3i', 'Wojkowice', 'Nawigacyjna', 60, 34573, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 237, 'KDbn7S', 'Chocianow', 'Na Bloniach', 280, 97683, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 238, 'yfBt3D', 'Sobotka', 'Oswiecimska', 381, 46910, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 239, 'xPOU8K', 'Chelmza', 'Fryderyka Chopina', 287, 44238, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 240, 'gFXu8d', 'Ropczyce', 'Tytusa Czyzewskiego', 364, 53775, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 241, 'Spbg3M', 'Chojnice', 'Rybna', 91, 52191, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 242, 'RqDf6X', 'Chelmza', 'Koscielna', 209, 73748, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 243, 'jBdN1J', 'Klobuck', 'Alojzego Kaczmarczyka', 347, 77643, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 244, 'CKZS7F', 'Wronki', 'Wapiennik', 21, 95582, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 245, 'suLX7r', 'Wloszczowa', 'Ludwika Wegierskiego', 114, 76480, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 246, 'iKsW2K', 'Ledziny', 'Marii Jaremy', 249, 37031, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 247, 'MLls8d', 'Lubsko', 'Kamedulska', 54, 54193, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 248, 'Imen3t', 'Zary', 'Margaretek', 7, 97708, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 249, 'kzJl4h', 'Puck', 'Jarzynowa', 489, 66792, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 250, 'NjqN2F', 'Orzesze', 'Gorna', 317, 53650, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 251, 'GmSU7Z', 'Konstancin-Jeziorna', 'Kazimierza Czapinskiego', 297, 19710, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 252, 'hnyV9a', 'Twardogora', 'Witolda Budryka', 407, 93698, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 253, 'BjmV6t', 'Bilgoraj', 'Edmunda Biernackiego', 174, 87232, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 254, 'LqCS0j', 'Ledziny', 'Dzielna', 182, 54609, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 255, 'qiPW8N', 'Kozy', 'Witkowicka', 194, 16012, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 256, 'Kqkm7y', 'Zarow', 'Bliska', 382, 93531, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 257, 'HPvp3P', 'Szczytno', 'Boleslawa Komorowskiego', 119, 38225, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 258, 'TjNb0e', 'Tczew', 'Bagatela', 275, 52199, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 259, 'qwxc1v', 'lowicz', 'Na Budzyniu', 422, 18448, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 260, 'YFIq5f', 'Pyskowice', 'Slotna', 47, 56542, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 261, 'zHOP9g', 'Gora', 'Jana Piwnika "Ponurego"', 428, 30353, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 262, 'WoHy5C', 'Skarzysko-Kamienna', 'Nad Sudolem', 470, 81485, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 263, 'QwuC4q', 'Zywiec', 'Pod Skala', 209, 57021, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 264, 'RRCE8R', 'Polkowice', 'Henryka Rodakowskiego', 480, 72255, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 265, 'OMvZ4q', 'Walbrzych', 'Tkacka', 237, 90691, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 266, 'WuFn5Z', 'Walbrzych', 'prof. Teodora Spiczakowa', 483, 67624, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 267, 'YqfJ9T', 'Gizycko', 'Bielanska', 472, 32594, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 268, 'eRuY0i', 'Nysa', 'Feliksa Kopery', 364, 15096, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 269, 'jyIs1i', 'Minsk_Mazowiecki', 'Stanislawa Grochowiaka', 336, 11657, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 270, 'pWfy2k', 'leczna', 'Kasztelanska', 10, 74155, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 271, 'bNPU4m', 'Sztum', 'Wladyslawa Raczkiewicza', 499, 97150, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 272, 'efsw1z', 'Niepolomice', 'Stawowa', 196, 28327, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 273, 'QKlL1l', 'Chelm', 'Puszczykow', 131, 76918, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 274, 'TQQn7R', 'sroda_Wielkopolska', 'Mlodej Polski', 173, 75138, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 275, 'Vniv7W', 'Rudnik_nad_Sanem', 'Zygmunta Mlynarskiego', 400, 81109, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 276, 'nfOn3u', 'Gora_Kalwaria', 'Sokola', 120, 31097, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 277, 'HhkP2D', 'Zielonka', 'Jeczmienna', 351, 74970, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 278, 'HOpi7e', 'Brzeziny', 'Narcyzowa', 197, 65760, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 279, 'mubx2x', 'Czeladz', 'Litewska', 480, 41282, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 280, 'PQID6H', 'Kozy', 'Palmowa', 141, 90003, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 281, 'XSuP2M', 'Szczekociny', 'Nad Zalewem', 10, 38597, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 282, 'lodm1V', 'Pyrzyce', 'Piastowska', 446, 41867, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 283, 'wWHY7W', 'Zory', 'Jagielka', 94, 70234, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 284, 'LXyc7p', 'Koscian', 'Poniedzialkowy Dol', 354, 93183, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 285, 'lrju7L', 'Sopot', 'Przeskok', 476, 17643, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 286, 'wRvU3y', 'Myslowice', 'bp. Jozefa Gawliny', 124, 88772, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 287, 'ewrn1z', 'Ogrodzieniec', 'Zakamycze', 450, 91521, false);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 288, 'bsXE9v', 'Przemysl', 'Biale Wzgorze', 321, 30633, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 289, 'CCWv6w', 'Limanowa', 'Smolenskusuniete', 146, 43267, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 290, 'XsEf1O', 'Szczawno-Zdroj', 'Krolewska', 399, 13656, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 291, 'bQVR8H', 'Sucha_Beskidzka', 'Soltysa Dytmara', 302, 15553, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 292, 'NtVu7g', 'Koluszki', 'Grabowa', 399, 69195, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 293, 'EHGF8M', 'Krzeszowice', 'Jazowa', 57, 64160, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 294, 'Inhx4i', 'Wegorzewo', 'Jozefitow', 178, 43861, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 295, 'IopY2C', 'Dabrowa_Gornicza', 'Krzyzowka', 392, 47695, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 296, 'snbg6T', 'Nowy_Dwor_Mazowiecki', 'Henryka Rodakowskiego', 87, 74437, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 297, 'SJjW8g', 'Polanica-Zdroj', 'Feliksa Konecznego', 1, 49089, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 298, 'xCat2R', 'Wronki', 'Ludwika Wegierskiego', 5, 95512, true);
INSERT INTO ppl.parcel_lockers( id, name, city, street, house_number, postal_code, is_active ) VALUES ( 299, 'OKNM3v', 'Strzyzow', 'Bularnia', 17, 33624, true);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 301, 'Dkbqse', 'lomza', 'Koziarowka', 365, 75746);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 302, 'Eoxmxe', 'Ostrzeszow', 'Gorka Narodowa', 459, 17943);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 303, 'Jwnpbt', 'Proszowice', 'Obopolna', 459, 54000);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 304, 'Qwlavb', 'Bierutow', 'Franciszka Kowalskiego', 340, 51564);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 305, 'Shcpyh', 'Braniewo', 'Nawojowska', 39, 50373);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 306, 'Farmmd', 'lapy', 'Bibicka', 12, 72793);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 307, 'Dfvkyn', 'Gniew', 'Ludwika Pasteura', 350, 34998);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 308, 'Khdgzp', 'Czarne', 'Nad zrodlem', 402, 78395);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 309, 'Yhjwhb', 'Elk', 'Porzeczkowa', 76, 29731);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 310, 'Fqhjhd', 'Nowa_Sol', 'Pod Fortem', 462, 92836);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 311, 'Domajg', 'Sobotka', 'Wroclawska', 382, 89744);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 312, 'Udnnjl', 'Gubin', 'Stanislawa Konarskiego', 2, 29979);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 313, 'Rerxsc', 'Walcz', 'Cichy Kacik', 368, 89548);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 314, 'Liqjxi', 'Dzialdowo', 'Droznicka', 478, 49551);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 315, 'Ulbdpy', 'Gniew', 'Gorna', 412, 45358);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 316, 'Nqshcp', 'Klodawa', 'Ludomira Benedyktowicza', 94, 99524);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 317, 'Hnghqj', 'Zielona_Gora', 'Kamedulska', 163, 89334);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 318, 'Ejogav', 'Chelmno', 'Daleka', 376, 35483);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 319, 'Nqywuv', 'swinoujscie', 'Hoza', 140, 32304);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 320, 'Lihcoh', 'Wrzesnia', 'Tadeusza Makowskiego', 115, 63420);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 321, 'Pyqoof', 'Olesnica', 'Gleboka', 404, 56065);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 322, 'Zswvtf', 'Olkusz', 'Misjonarska', 380, 16948);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 323, 'Wvhodb', 'Nowy_Tomysl', 'os.Krowodrza Gorka', 391, 13614);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 324, 'Voxsqa', 'Jarocin', 'Kiejstuta zemaitisa', 447, 71475);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 325, 'Ovtjow', 'Minsk_Mazowiecki', 'Puszczykow', 262, 50565);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 326, 'Gglobw', 'Brzesko', 'Astronomow', 26, 41909);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 327, 'Hunkwx', 'Wielun', 'Gaik', 173, 37165);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 328, 'Mcocqv', 'Golub-Dobrzyn', 'Orna', 240, 21288);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 329, 'Uablhy', 'sroda_Wielkopolska', 'Krancowa', 453, 41476);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 330, 'Jbtoyu', 'Miedzychod', 'Na Nowinach', 285, 72307);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 331, 'Itqqex', 'Sopot', 'Stanislawa Ciechanowskiego', 279, 28226);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 332, 'Bjkkbs', 'swinoujscie', 'Obozna', 286, 13069);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 333, 'Olmlml', 'Kudowa-Zdroj', 'Ludwika Wegierskiego', 449, 27396);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 334, 'Uionki', 'Grudziadz', 'Astronautow', 107, 30909);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 335, 'Dbcrke', 'lapy', 'Kornela Ujejskiego', 162, 13459);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 336, 'Mzyexl', 'Czarnkow', 'Wladyslawa Podkowinskiego', 74, 71563);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 337, 'Vcfkiv', 'Siedlce', 'Grzegorza Korzeniaka', 340, 62485);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 338, 'Krmcyr', 'Lubsko', 'Jadwigi Majowny', 468, 85009);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 339, 'Wfoqia', 'Rumia', 'Kmieca', 281, 65576);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 340, 'Dzpnfm', 'sroda_slaska', 'Franciszka Bielaka', 146, 68551);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 341, 'Fwetot', 'Nasielsk', 'Zakliki z Mydlnik', 407, 34645);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 342, 'Wjrlhk', 'Stronie_slaskie', 'Poreba', 168, 73250);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 343, 'Fyjwbs', 'Zdzieszowice', 'Agrestowa', 361, 99928);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 344, 'Objcgm', 'Ostrowiec_swietokrzyski', 'Czeslawa Niemena', 308, 52810);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 345, 'Xgqmxn', 'Szydlowiec', 'Jasnogorska', 358, 18245);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 346, 'Ceonrq', 'Poddebice', 'Skladowa', 29, 87211);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 347, 'Vhejmx', 'Gorlice', 'Kaszubska', 225, 60444);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 348, 'Cojxox', 'Polkowice', 'Podchorazych', 267, 54388);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 349, 'Reurhs', 'Plock', 'Witolda Budryka', 312, 85271);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 350, 'Xbdzyy', 'Katowice', 'Kopalina', 344, 26464);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 351, 'Juhmsx', 'Kudowa-Zdroj', 'swietokrzyska', 432, 12547);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 352, 'Lzxxto', 'Przemysl', 'Stefana Jaracza', 252, 26593);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 353, 'Lssmqe', 'swinoujscie', 'Jadwigi z lobzowa', 249, 89803);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 354, 'Inepzg', 'Lebork', 'al.Konarowa', 365, 24320);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 355, 'Jnfjdu', 'Sulecin', 'Redzina', 417, 94946);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 356, 'Upnlih', 'Strzelce_Krajenskie', 'Karola Szymanowskiego', 217, 62176);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 357, 'Iaesvk', 'Jastrzebie-Zdroj', 'Szaserow', 82, 10706);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 358, 'Qggnim', 'Pyrzyce', 'al.Jerzego Waszyngtona', 329, 61662);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 359, 'Jbdjba', 'Cieszyn', 'Jozefa Wybickiego', 191, 10529);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 360, 'Himpuc', 'Bialogard', 'Syreny', 227, 79847);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 361, 'Yckvmb', 'Trzebinia', 'Olszanicka', 414, 36607);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 362, 'Jovylt', 'Trzebinia', 'Akademicka', 30, 67894);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 363, 'Ozxfbj', 'Bierun_Ledziny', 'Emaus', 419, 88946);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 364, 'Ksbnxs', 'Dlugoleka', 'Zaklucze', 218, 63503);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 365, 'Ncwquj', 'Choszczno', 'Orna', 257, 35357);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 366, 'Uiqoiv', 'Bielsko-Biala', 'os.Srebrne Uroczysko', 152, 11340);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 367, 'Pxvgtn', 'Bierun_Ledziny', 'Zakret', 319, 40010);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 368, 'Xqghuj', 'Wielun', 'Mieczyslawa Karlowicza', 358, 79299);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 369, 'Dkhceg', 'Krasnik', 'Mrowczana', 188, 97416);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 370, 'Gznxwv', 'Belzyce', 'Olkuska', 124, 16198);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 371, 'Xqzyxp', 'swidnik', 'Daniela Chodowieckiego', 368, 17434);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 372, 'Mikces', 'Kolobrzeg', 'Baltycka', 338, 85069);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 373, 'Mqddml', 'lomianki', 'Koralowa', 402, 98923);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 374, 'Hlrkyu', 'Minsk_Mazowiecki', 'Tkacka', 12, 79582);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 375, 'Cqwqyw', 'Raciborz', 'Rzepichy', 225, 27138);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 376, 'Tktxmw', 'Pleszew', 'Filtrowa', 8, 12494);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 377, 'Dktjqo', 'Klodawa', 'Biala', 124, 15546);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 378, 'Fxbkij', 'Jaroslaw', 'Borowczana', 21, 20062);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 379, 'Imshou', 'Goldap', 'Jozefa Rostafinskiego', 74, 82892);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 380, 'Yphole', 'Imielin', 'Emilii Plater', 392, 24884);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 381, 'Hlosdb', 'Zlotow', 'Podluzna', 54, 82644);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 382, 'Kccsjs', 'Znin', 'Zakamycze', 490, 78653);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 383, 'Tdiqnh', 'Rawa_Mazowiecka', 'Biale Wzgorze', 338, 84838);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 384, 'Sdyfwv', 'Bolkow', 'Mieczyslawa Maleckiego', 245, 42497);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 385, 'Vxtfbx', 'Ostrow_Wielkopolski', 'Jana Buszka', 383, 20782);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 386, 'Qsgmhp', 'Brzeg_Dolny', 'Zaczarowane Kolo', 317, 34291);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 387, 'Xwgbto', 'Chelmza', 'Bibicka', 244, 23159);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 388, 'Wjndka', 'Brzeg_Dolny', 'Porzecze', 469, 92871);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 389, 'Dizlbv', 'Pruszkow', 'Berberysowa', 345, 58118);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 390, 'Edblcr', 'Zdzieszowice', 'Amazonek', 124, 48379);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 391, 'Bshpby', 'Poznan', 'Adama Staszczyka', 270, 50017);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 392, 'Kxllwp', 'Zabrze', 'Skladowa', 332, 55855);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 393, 'Tkkbup', 'Tarnobrzeg', 'Brzegowa', 423, 62893);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 394, 'Lehyvg', 'Goldap', 'Karola Popiela', 49, 97279);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 395, 'Cmarwz', 'Krasnystaw', 'Wiedenska', 337, 87776);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 396, 'Vookhc', 'Luban', 'Turystyczna', 168, 91698);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 397, 'Loplwe', 'Pyrzyce', 'Adama Chmiela', 86, 59833);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 398, 'Nqbism', 'Grodzisk_Mazowiecki', 'Gnieznienska', 438, 97297);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 399, 'Ypykdy', 'Naklo_nad_Notecia', 'Kaczorowka', 386, 40448);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 400, 'Ymhisw', 'Pruszcz_Gdanski', 'Zygmunta Starego', 367, 35873);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 401, 'Niatnb', 'Wolomin', 'Skotnica', 310, 94080);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 402, 'Ttntze', 'Zelow', 'Wincentego Danka', 344, 54050);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 403, 'Jnhohz', 'Ilawa', 'Maczna', 152, 28363);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 404, 'Flavfj', 'Olecko', 'Torunska', 215, 96140);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 405, 'Cijljn', 'Reda', 'Redzina', 190, 75024);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 406, 'Iekiby', 'Zbaszyn', 'Mlaskotow', 146, 27010);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 407, 'Dmvrlc', 'Proszowice', 'Drozyna', 466, 53114);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 408, 'Gotskm', 'Sierpc', 'Nad Zalewem', 342, 95774);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 409, 'Bxnfiq', 'Rawicz', 'Wernyhory', 136, 80282);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 410, 'Ymxxqi', 'Skoczow', 'Wojciecha Halczyna', 263, 60398);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 411, 'Twupdo', 'Zakopane', 'Stanislawa Rokosza', 384, 30984);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 412, 'Airbdf', 'Orzesze', 'Marii Jaremy', 292, 71821);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 413, 'Hqhjgv', 'Plonsk', 'Aleksandra Prystora', 454, 67011);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 414, 'Nemfsk', 'Ropczyce', 'Wiosenna', 376, 43672);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 415, 'Nxixud', 'Siechnice', 'Zaborska', 248, 68251);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 416, 'Sufjqt', 'Debica', 'Eugeniusza Romera', 469, 18840);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 417, 'Vbxdnu', 'Kowary', 'Juliana Tokarskiego', 82, 63696);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 418, 'Arqwbj', 'Tarnow', 'Zygmunta Starego', 273, 78346);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 419, 'Rektdf', 'Pszczyna', 'Gabrieli Zapolskiej', 12, 71060);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 420, 'Txsqyj', 'Pinczow', 'Daniela Chodowieckiego', 498, 46619);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 421, 'Tmvige', 'Zagan', 'Bibicka', 348, 50631);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 422, 'Oundbd', 'Rawicz', 'Malownicza', 388, 13082);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 423, 'Hhvtxr', 'Nowy_Dwor_Gdanski', 'Stelmachow', 282, 75858);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 424, 'Psrqpe', 'Sanok', 'Przyjemna', 303, 65058);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 425, 'Ducduk', 'Sosnowiec', 'Jana Stanislawskiego', 368, 81409);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 426, 'Olieqi', 'Pabianice', 'Tadeusza Ochlewskiego', 356, 15602);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 427, 'Kshpbr', 'Kety', 'Kopalina', 4, 43793);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 428, 'Wtlxlr', 'Jelenia_Gora', 'Niezapominajek', 33, 40599);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 429, 'Jojgkt', 'Debica', 'Przepiorcza', 77, 80909);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 430, 'Shkmki', 'Olecko', 'Mieczyslawa Karlowicza', 373, 48304);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 431, 'Zjhepf', 'Konstancin-Jeziorna', 'inneKopiec Kosciuszki', 142, 93927);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 432, 'Tshibq', 'Miedzyrzecz', 'Zygmunta Myslakowskiego', 269, 56396);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 433, 'Qpxrdf', 'Plonsk', 'Poniedzialkowy Dol', 404, 37518);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 434, 'Xxufsd', 'Lubawka', 'Jozefa Friedleina', 437, 24209);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 435, 'Epqxmh', 'Gniezno', 'Dziewanny', 455, 75638);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 436, 'Wpyfwr', 'Grudziadz', 'Jaskolcza', 266, 62748);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 437, 'Gdkswp', 'Bierutow', 'Mlodej Polski', 302, 38600);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 438, 'Unspeu', 'Rawicz', 'Nawigacyjna', 69, 21279);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 439, 'Abqbif', 'Strzelce_Krajenskie', 'Piotra Kluzeka', 168, 90154);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 440, 'Yuscer', 'Skawina', 'Jerzego Samuela Bandtkiego', 361, 75222);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 441, 'Giosvr', 'Limanowa', 'Wladyslawa lokietka', 87, 98619);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 442, 'Sjxxfv', 'Tuszyn', 'Waleczna', 392, 46096);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 443, 'Otehxb', 'Gniew', 'dr. Twardego', 385, 84819);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 444, 'Jgsxpx', 'Bydgoszcz', 'Ksiecia Jozefa', 20, 55372);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 445, 'Ngbimp', 'Nowy_Sacz', 'Wladyslawa Syrokomli', 50, 18722);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 446, 'Vaaxxg', 'Andrychow', 'Pod Szancami', 23, 22352);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 447, 'Pfhwef', 'Tomaszow_Mazowiecki', 'Warmijska', 44, 11387);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 448, 'Rhvign', 'Belzyce', 'Nad Zalewem', 373, 12994);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 449, 'Dewsga', 'swiecie', 'Na Wyrebe', 350, 45060);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 450, 'Xcjeej', 'sroda_slaska', 'Eugeniusza Romera', 57, 55709);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 451, 'Duevxe', 'Polkowice', 'Owsiana', 72, 21400);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 452, 'Vfrouy', 'Radom', 'Boleslawa Komorowskiego', 9, 49447);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 453, 'Ymkjrz', 'Stalowa_Wola', 'Wladyslawa lokietka', 439, 80739);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 454, 'Vceqvh', 'Siewierz', 'Boleslawa Czerwienskiego', 481, 34185);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 455, 'Twphkr', 'Lubawka', 'Zbrojow', 121, 57567);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 456, 'Hikorf', 'Glogow', 'Porzecze', 176, 88736);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 457, 'Pgosbg', 'Krzeszowice', 'Kazimierza Puzaka', 143, 82817);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 458, 'Cxjauj', 'Trzebnica', 'Zygmunta Wyrobka', 274, 42428);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 459, 'Syaxkf', 'Nowa_Sol', 'Jozefa Rostafinskiego', 387, 79909);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 460, 'Cwqyql', 'Szklarska_Poreba', 'Ludwika Muzyczki', 490, 96758);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 461, 'Vxvygl', 'Sosnowiec', 'Bodziszkowa', 4, 31499);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 462, 'Wdzkgc', 'Kobylka', 'prof. Stefana Myczkowskiego', 496, 78981);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 463, 'Zptvll', 'Zary', 'Gnieznienska', 51, 99428);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 464, 'Dqkiua', 'Nisko', 'Justowska', 173, 69418);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 465, 'Uqwtst', 'Sochaczew', 'Kiejstuta zemaitisa', 190, 63405);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 466, 'Ewfswq', 'Zychlin', 'Gorka Narodowa', 121, 57966);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 467, 'Betwkb', 'Nowa_Deba', 'Halki', 262, 20052);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 468, 'Mrysrt', 'Nasielsk', 'Zimorodkow', 320, 17149);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 469, 'Jhnsln', 'Jedrzejow', 'Margaretek', 500, 24567);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 470, 'Bufyrp', 'Ustrzyki_Dolne', 'Orlich Gniazd', 478, 50477);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 471, 'Uzclcr', 'Gdynia', 'Witkowicka', 398, 41704);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 472, 'Jukifn', 'Bytow', 'Jacka Malczewskiego', 157, 76778);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 473, 'Xygyvz', 'Pyrzyce', 'Edmunda Biernackiego', 479, 21686);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 474, 'Ndaysb', 'Wyszkow', 'Podchorazych', 113, 46436);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 475, 'Krvtpz', 'Lezajsk', 'Zakliki z Mydlnik', 21, 83476);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 476, 'Yijfwk', 'Sosnowiec', 'Gryczana', 229, 11687);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 477, 'Iwsnpq', 'Koluszki', 'Sarnie Uroczysko', 211, 82108);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 478, 'Zkcbws', 'Oborniki', 'Kopalina', 34, 84637);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 479, 'Bmtqjs', 'Miedzychod', 'Brazownicza', 21, 76098);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 480, 'Ipykte', 'Ostrzeszow', 'lukasza Gornickiego', 490, 37669);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 481, 'Fvpsrf', 'Mikolow', 'inneLas Wolski', 46, 13962);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 482, 'Odelrn', 'Gizycko', 'Gzymsikow', 294, 97293);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 483, 'Edsfqa', 'Nowy_Sacz', 'Strzelnica', 421, 77144);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 484, 'Shneug', 'Pszczyna', 'Sosnowiecka', 259, 65088);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 485, 'Ukecrl', 'Legnica', 'Orla', 407, 87921);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 486, 'Ufdfkr', 'Lubon', 'Jesionowa', 53, 95513);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 487, 'Doyltr', 'Zdunska_Wola', 'Vlastimila Hofmana', 156, 60793);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 488, 'Jhrqmf', 'Strzelce_Krajenskie', 'Zimorodkow', 63, 77501);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 489, 'Qqktip', 'Sosnowiec', 'Soltysa Dytmara', 287, 51240);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 490, 'Ijured', 'Radlin', 'al.Kijowska', 231, 73836);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 491, 'Xicftf', 'Zgorzelec', 'Przepiorcza', 415, 56284);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 492, 'Tongjt', 'Wodzislaw_slaski', 'Droznicka', 419, 43198);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 493, 'Elmlvu', 'Zabrze', 'Poziomkowa', 200, 22774);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 494, 'Xnxzck', 'Skarszewy', 'Kadrowki', 161, 95191);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 495, 'Bsckyj', 'Szczecinek', 'Jodlowa', 253, 75733);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 496, 'Budell', 'Klodzko', 'Chabrowa', 195, 38853);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 497, 'Fdruzt', 'Krzeszowice', 'Na Polankach', 101, 45051);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 498, 'Dxgmbo', 'Lezajsk', 'Gradowa', 90, 22473);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 499, 'Wwrdqx', 'lomza', 'dr. Tadeusza Kudlinskiego', 227, 32446);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 500, 'Gkwbqo', 'Trzebnica', 'Ryszarda Berwinskiego', 258, 73860);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 501, 'Ycsoeb', 'Oswiecim', 'Bazancia', 224, 55667);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 502, 'Nrebdo', 'Kudowa-Zdroj', 'Wewnetrzna', 234, 59295);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 503, 'Zgwyxg', 'Gora_Kalwaria', 'Kolowa', 227, 85454);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 504, 'Avbhyl', 'Sulechow', 'Krakusow', 212, 19803);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 505, 'Eeiwpb', 'Brzeg_Dolny', 'Urodzajna', 339, 65693);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 506, 'Ruggpd', 'Hajnowka', 'Wapiennik', 61, 90437);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 507, 'Dhrkqs', 'swietochlowice', 'Konwisarzy', 485, 24671);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 508, 'Hfpbqi', 'Piensk', 'Wapiennik', 166, 11998);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 509, 'Xcoomz', 'Zielona_Gora', 'Dziewanny', 117, 37172);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 510, 'Jvbedc', 'Goldap', 'Pod Strzecha', 342, 11972);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 511, 'Eqickc', 'Pobiedziska', 'Adama Chmiela', 441, 83712);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 512, 'Ksegcd', 'Debno', 'Glogowiec', 72, 69084);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 513, 'Lxqhym', 'Wielun', 'Nad zrodlem', 128, 65307);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 514, 'Oeligg', 'Szklarska_Poreba', 'Skalna', 54, 52162);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 515, 'Gjyvpn', 'Wagrowiec', 'Starowolska', 273, 84268);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 516, 'Xweftw', 'Wasilkow', 'al.Modrzewiowa', 336, 52219);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 517, 'Kevwwd', 'Prabuty', 'Jozefa Mackiewicza', 487, 33450);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 518, 'Pwnvsj', 'Torun', 'Piotra Stachiewicza', 73, 36817);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 519, 'Dsmacv', 'Wladyslawowo', 'Stanislawa Kasznicy', 321, 46668);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 520, 'Omriry', 'Duszniki-Zdroj', 'Gospodarska', 60, 77600);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 521, 'Lrjluq', 'Chodziez', 'Zefirowa', 274, 40641);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 522, 'Hcmxga', 'Strzyzow', 'Smetna', 187, 96992);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 523, 'Qfndss', 'Wejherowo', 'Na Zielonki', 86, 36227);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 524, 'Muzgcr', 'Piensk', 'Orla', 459, 74768);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 525, 'Kwwtel', 'Glowno', 'Czeladnicza', 94, 52112);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 526, 'Vqfnbj', 'Zmigrod', 'Bazancia', 351, 32681);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 527, 'Bsjsuq', 'Siemianowice_slaskie', 'Obopolna', 175, 33893);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 528, 'Klgkhv', 'Torun', 'Morelowa', 162, 28394);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 529, 'Xyrvpb', 'Kartuzy', 'Gajowka', 85, 12902);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 530, 'Ekhciq', 'Miedzychod', 'Nasza', 227, 53441);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 531, 'Mrdkvs', 'lobez', 'Jarzynowa', 296, 52743);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 532, 'Xqxtym', 'Lubsko', 'Nad zrodlem', 349, 13151);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 533, 'Zqawbr', 'Terespol', 'Jasnogorska', 168, 13535);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 534, 'Frxhuy', 'Strzelin', 'Zielinska', 455, 45798);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 535, 'Tpeeus', 'Rabka-Zdroj', 'Lubelska', 376, 78938);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 536, 'Igmenh', 'Brzeg_Dolny', 'Piotra Wysockiego', 377, 69625);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 537, 'Wxlkii', 'Wojkowice', 'Nawigacyjna', 60, 34573);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 538, 'Kdbnus', 'Chocianow', 'Na Bloniach', 280, 97683);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 539, 'Yfbtjd', 'Sobotka', 'Oswiecimska', 381, 46910);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 540, 'Xpouxk', 'Chelmza', 'Fryderyka Chopina', 287, 44238);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 541, 'Gfxuxd', 'Ropczyce', 'Tytusa Czyzewskiego', 364, 53775);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 542, 'Spbgjm', 'Chojnice', 'Rybna', 91, 52191);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 543, 'Rqdfqx', 'Chelmza', 'Koscielna', 209, 73748);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 544, 'Jbdnej', 'Klobuck', 'Alojzego Kaczmarczyka', 347, 77643);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 545, 'Ckzssf', 'Wronki', 'Wapiennik', 21, 95582);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 546, 'Sulxvr', 'Wloszczowa', 'Ludwika Wegierskiego', 114, 76480);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 547, 'Ikswfk', 'Ledziny', 'Marii Jaremy', 249, 37031);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 548, 'Mllsvd', 'Lubsko', 'Kamedulska', 54, 54193);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 549, 'Imenkt', 'Zary', 'Margaretek', 7, 97708);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 550, 'Kzjlkh', 'Puck', 'Jarzynowa', 490, 66792);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 551, 'Njqngf', 'Orzesze', 'Gorna', 317, 53650);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 552, 'Gmsuuz', 'Konstancin-Jeziorna', 'Kazimierza Czapinskiego', 297, 19710);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 553, 'Hnyvza', 'Twardogora', 'Witolda Budryka', 407, 93698);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 554, 'Bjmvqt', 'Bilgoraj', 'Edmunda Biernackiego', 174, 87232);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 555, 'Lqcsaj', 'Ledziny', 'Dzielna', 182, 54609);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 556, 'Qipwxn', 'Kozy', 'Witkowicka', 194, 16012);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 557, 'Kqkmty', 'Zarow', 'Bliska', 382, 93531);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 558, 'Hpvpip', 'Szczytno', 'Boleslawa Komorowskiego', 119, 38225);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 559, 'Tjnbbe', 'Tczew', 'Bagatela', 275, 52199);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 560, 'Qwxcdv', 'lowicz', 'Na Budzyniu', 423, 18448);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 561, 'Yfiqnf', 'Pyskowice', 'Slotna', 46, 56542);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 562, 'Zhopzg', 'Gora', 'Jana Piwnika "Ponurego"', 428, 30353);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 563, 'Wohyoc', 'Skarzysko-Kamienna', 'Nad Sudolem', 470, 81485);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 564, 'Qwuclq', 'Zywiec', 'Pod Skala', 209, 57021);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 565, 'Rrcexr', 'Polkowice', 'Henryka Rodakowskiego', 480, 72255);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 566, 'Omvzmq', 'Walbrzych', 'Tkacka', 237, 90691);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 567, 'Wufnpz', 'Walbrzych', 'prof. Teodora Spiczakowa', 483, 67624);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 568, 'Yqfjzt', 'Gizycko', 'Bielanska', 473, 32594);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 569, 'Eruybi', 'Nysa', 'Feliksa Kopery', 365, 15096);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 570, 'Jyisci', 'Minsk_Mazowiecki', 'Stanislawa Grochowiaka', 336, 11657);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 571, 'Pwfyfk', 'leczna', 'Kasztelanska', 10, 74155);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 572, 'Bnpukm', 'Sztum', 'Wladyslawa Raczkiewicza', 500, 97150);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 573, 'Efswcz', 'Niepolomice', 'Stawowa', 196, 28327);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 574, 'Qkllel', 'Chelm', 'Puszczykow', 131, 76918);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 575, 'Tqqntr', 'sroda_Wielkopolska', 'Mlodej Polski', 173, 75138);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 576, 'Vnivtw', 'Rudnik_nad_Sanem', 'Zygmunta Mlynarskiego', 401, 81109);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 577, 'Nfonju', 'Gora_Kalwaria', 'Sokola', 120, 31097);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 578, 'Hhkpgd', 'Zielonka', 'Jeczmienna', 351, 74970);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 579, 'Hopite', 'Brzeziny', 'Narcyzowa', 197, 65760);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 580, 'Mubxgx', 'Czeladz', 'Litewska', 481, 41282);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 581, 'Pqidqh', 'Kozy', 'Palmowa', 141, 90003);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 582, 'Xsupgm', 'Szczekociny', 'Nad Zalewem', 9, 38597);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 583, 'Lodmdv', 'Pyrzyce', 'Piastowska', 447, 41867);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 584, 'Wwhyuw', 'Zory', 'Jagielka', 94, 70234);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 585, 'Lxycup', 'Koscian', 'Poniedzialkowy Dol', 354, 93183);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 586, 'Lrjuvl', 'Sopot', 'Przeskok', 477, 17643);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 587, 'Wrvuiy', 'Myslowice', 'bp. Jozefa Gawliny', 124, 88772);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 588, 'Ewrncz', 'Ogrodzieniec', 'Zakamycze', 450, 91521);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 589, 'Bsxezv', 'Przemysl', 'Biale Wzgorze', 321, 30633);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 590, 'Ccwvsw', 'Limanowa', 'Smolenskusuniete', 146, 43267);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 591, 'Xsefco', 'Szczawno-Zdroj', 'Krolewska', 399, 13656);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 592, 'Bqvrxh', 'Sucha_Beskidzka', 'Soltysa Dytmara', 302, 15553);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 593, 'Ntvuug', 'Koluszki', 'Grabowa', 399, 69195);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 594, 'Ehgfvm', 'Krzeszowice', 'Jazowa', 56, 64160);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 595, 'Inhxmi', 'Wegorzewo', 'Jozefitow', 178, 43861);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 596, 'Iopyhc', 'Dabrowa_Gornicza', 'Krzyzowka', 393, 47695);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 597, 'Snbgrt', 'Nowy_Dwor_Mazowiecki', 'Henryka Rodakowskiego', 87, 74437);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 598, 'Sjjwwg', 'Polanica-Zdroj', 'Feliksa Konecznego', 1, 49089);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 599, 'Xcatfr', 'Wronki', 'Ludwika Wegierskiego', 4, 95512);
INSERT INTO ppl.places( id, name, city, street, house_number, postal_code ) VALUES ( 600, 'Oknmiv', 'Strzyzow', 'Bularnia', 17, 33624);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 466, 'WED', 5, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 480, 'THU', 17, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 400, 'WED', 0, 3);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 376, 'MON', 16, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 416, 'SAT', 20, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 596, 'SAT', 9, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 353, 'SUN', 1, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 339, 'WED', 5, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 512, 'SUN', 5, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 465, 'TUE', 5, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 332, 'FRI', 2, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 376, 'FRI', 2, 3);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 488, 'WED', 0, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 533, 'FRI', 5, 6);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 594, 'SAT', 3, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 598, 'WED', 1, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 507, 'WED', 3, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 524, 'MON', 11, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 520, 'TUE', 18, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 546, 'FRI', 8, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 459, 'THU', 4, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 518, 'FRI', 3, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 570, 'WED', 4, 6);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 341, 'WED', 2, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 356, 'TUE', 12, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 517, 'WED', 14, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 320, 'WED', 0, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 408, 'MON', 9, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 501, 'FRI', 17, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 405, 'TUE', 0, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 482, 'THU', 15, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 558, 'THU', 4, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 580, 'MON', 11, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 560, 'FRI', 17, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 362, 'FRI', 4, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 508, 'WED', 12, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 585, 'MON', 7, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 514, 'MON', 8, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 507, 'THU', 9, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 419, 'MON', 6, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 584, 'FRI', 7, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 486, 'MON', 1, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 419, 'WED', 5, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 484, 'MON', 7, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 579, 'FRI', 0, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 599, 'FRI', 14, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 565, 'SUN', 13, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 444, 'FRI', 6, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 352, 'WED', 2, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 344, 'SAT', 12, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 358, 'TUE', 5, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 518, 'WED', 13, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 504, 'TUE', 9, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 498, 'THU', 10, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 442, 'THU', 4, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 591, 'FRI', 0, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 413, 'WED', 1, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 315, 'THU', 9, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 537, 'THU', 5, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 301, 'SAT', 12, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 334, 'WED', 0, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 445, 'MON', 11, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 405, 'FRI', 2, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 531, 'SAT', 12, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 516, 'MON', 5, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 451, 'MON', 3, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 393, 'FRI', 14, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 518, 'TUE', 10, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 316, 'TUE', 2, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 357, 'THU', 11, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 304, 'TUE', 0, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 359, 'SUN', 0, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 407, 'THU', 0, 4);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 547, 'MON', 0, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 551, 'TUE', 3, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 523, 'WED', 2, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 393, 'MON', 3, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 391, 'WED', 0, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 394, 'MON', 7, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 563, 'WED', 11, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 450, 'SAT', 3, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 453, 'THU', 1, 6);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 361, 'WED', 8, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 444, 'TUE', 3, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 512, 'MON', 0, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 383, 'SUN', 4, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 304, 'WED', 19, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 588, 'THU', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 529, 'SUN', 1, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 371, 'MON', 6, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 471, 'TUE', 5, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 417, 'MON', 1, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 351, 'WED', 10, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 475, 'SAT', 2, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 302, 'THU', 12, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 479, 'SUN', 9, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 318, 'MON', 0, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 527, 'WED', 6, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 429, 'THU', 2, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 423, 'WED', 4, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 502, 'MON', 4, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 405, 'MON', 10, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 523, 'SAT', 16, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 552, 'SAT', 3, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 313, 'FRI', 1, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 463, 'WED', 2, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 485, 'MON', 6, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 592, 'THU', 13, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 307, 'SUN', 7, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 485, 'WED', 18, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 424, 'FRI', 18, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 309, 'TUE', 0, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 507, 'FRI', 13, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 391, 'THU', 19, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 396, 'THU', 2, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 425, 'SAT', 14, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 307, 'WED', 9, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 579, 'WED', 13, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 498, 'FRI', 5, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 394, 'TUE', 3, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 477, 'MON', 7, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 335, 'THU', 2, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 392, 'MON', 19, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 506, 'FRI', 8, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 546, 'MON', 4, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 478, 'MON', 5, 6);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 377, 'MON', 9, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 314, 'TUE', 15, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 365, 'WED', 6, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 487, 'SAT', 9, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 401, 'MON', 0, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 376, 'WED', 4, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 521, 'MON', 1, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 390, 'FRI', 15, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 324, 'FRI', 5, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 528, 'FRI', 0, 6);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 314, 'WED', 9, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 513, 'WED', 7, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 326, 'TUE', 13, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 583, 'SAT', 19, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 326, 'WED', 4, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 521, 'WED', 3, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 353, 'FRI', 16, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 354, 'FRI', 4, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 303, 'WED', 17, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 382, 'MON', 9, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 372, 'THU', 2, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 454, 'MON', 8, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 584, 'TUE', 9, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 383, 'MON', 10, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 408, 'WED', 3, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 577, 'MON', 5, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 343, 'FRI', 8, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 503, 'WED', 7, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 488, 'TUE', 5, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 328, 'WED', 1, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 576, 'WED', 14, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 476, 'THU', 9, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 502, 'SUN', 7, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 520, 'MON', 3, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 468, 'THU', 13, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 362, 'TUE', 10, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 345, 'WED', 0, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 512, 'FRI', 5, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 364, 'MON', 14, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 441, 'TUE', 1, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 473, 'WED', 3, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 542, 'FRI', 4, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 590, 'SAT', 2, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 342, 'MON', 8, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 330, 'WED', 5, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 501, 'WED', 14, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 429, 'WED', 11, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 374, 'MON', 6, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 432, 'SUN', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 359, 'MON', 10, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 340, 'WED', 2, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 510, 'WED', 7, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 346, 'TUE', 8, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 543, 'WED', 8, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 517, 'MON', 17, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 501, 'THU', 10, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 457, 'TUE', 19, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 587, 'THU', 2, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 386, 'MON', 9, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 595, 'TUE', 5, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 452, 'FRI', 19, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 301, 'MON', 2, 4);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 484, 'TUE', 1, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 363, 'SUN', 7, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 341, 'TUE', 5, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 310, 'MON', 4, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 372, 'WED', 3, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 326, 'SAT', 14, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 551, 'MON', 11, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 422, 'MON', 9, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 367, 'MON', 5, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 356, 'WED', 8, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 389, 'THU', 6, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 473, 'MON', 12, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 416, 'THU', 9, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 412, 'TUE', 8, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 371, 'FRI', 22, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 462, 'MON', 4, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 567, 'MON', 6, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 383, 'WED', 12, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 502, 'TUE', 8, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 437, 'MON', 9, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 333, 'FRI', 11, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 581, 'MON', 5, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 437, 'SAT', 5, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 411, 'WED', 5, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 419, 'FRI', 8, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 408, 'TUE', 15, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 302, 'FRI', 1, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 390, 'MON', 0, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 311, 'MON', 15, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 537, 'WED', 3, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 426, 'THU', 3, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 388, 'SUN', 2, 4);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 402, 'WED', 11, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 379, 'TUE', 1, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 469, 'TUE', 5, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 487, 'MON', 2, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 567, 'WED', 6, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 425, 'TUE', 16, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 547, 'FRI', 3, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 563, 'TUE', 6, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 519, 'FRI', 7, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 532, 'THU', 2, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 410, 'MON', 13, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 347, 'MON', 1, 2);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 569, 'FRI', 9, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 406, 'THU', 2, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 373, 'WED', 4, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 336, 'WED', 8, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 589, 'WED', 14, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 486, 'WED', 1, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 350, 'WED', 4, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 310, 'SUN', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 443, 'MON', 2, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 368, 'WED', 2, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 343, 'MON', 1, 4);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 395, 'SUN', 4, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 464, 'WED', 7, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 411, 'TUE', 6, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 424, 'MON', 2, 3);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 487, 'TUE', 0, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 366, 'MON', 13, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 531, 'WED', 10, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 459, 'TUE', 5, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 563, 'SUN', 7, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 332, 'THU', 5, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 477, 'FRI', 1, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 426, 'TUE', 9, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 427, 'WED', 4, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 501, 'MON', 5, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 467, 'MON', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 523, 'TUE', 9, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 576, 'THU', 11, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 413, 'FRI', 0, 3);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 582, 'MON', 2, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 351, 'SAT', 13, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 399, 'FRI', 0, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 545, 'THU', 4, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 352, 'THU', 0, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 409, 'THU', 9, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 413, 'SAT', 6, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 532, 'SAT', 2, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 457, 'MON', 1, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 501, 'TUE', 2, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 484, 'FRI', 8, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 386, 'WED', 2, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 395, 'FRI', 1, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 388, 'WED', 1, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 328, 'MON', 13, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 403, 'SAT', 6, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 564, 'FRI', 2, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 450, 'WED', 1, 2);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 495, 'THU', 11, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 478, 'TUE', 9, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 412, 'THU', 2, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 354, 'WED', 1, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 583, 'SUN', 15, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 585, 'THU', 11, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 309, 'WED', 1, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 497, 'TUE', 2, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 357, 'SAT', 3, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 355, 'FRI', 17, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 587, 'MON', 3, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 490, 'MON', 14, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 535, 'MON', 8, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 343, 'SAT', 16, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 600, 'THU', 7, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 550, 'THU', 8, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 577, 'SAT', 1, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 507, 'MON', 1, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 421, 'THU', 0, 1);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 443, 'FRI', 13, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 388, 'MON', 7, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 550, 'MON', 16, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 326, 'MON', 15, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 522, 'MON', 6, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 496, 'TUE', 12, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 458, 'MON', 13, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 479, 'MON', 0, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 379, 'WED', 2, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 387, 'FRI', 5, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 367, 'SAT', 6, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 445, 'TUE', 2, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 447, 'MON', 7, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 506, 'SAT', 10, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 331, 'WED', 13, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 527, 'THU', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 437, 'WED', 0, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 592, 'MON', 18, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 415, 'FRI', 18, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 404, 'FRI', 14, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 430, 'WED', 5, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 441, 'WED', 13, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 482, 'MON', 0, 6);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 395, 'TUE', 0, 3);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 386, 'TUE', 16, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 308, 'TUE', 2, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 414, 'TUE', 0, 3);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 538, 'MON', 13, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 302, 'SAT', 5, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 410, 'SAT', 8, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 316, 'WED', 10, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 418, 'SUN', 18, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 328, 'FRI', 0, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 506, 'WED', 18, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 311, 'WED', 2, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 431, 'WED', 8, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 578, 'WED', 0, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 496, 'THU', 9, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 527, 'TUE', 8, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 334, 'THU', 9, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 374, 'SAT', 1, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 434, 'WED', 1, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 392, 'FRI', 10, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 319, 'THU', 21, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 454, 'WED', 7, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 392, 'WED', 15, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 475, 'WED', 7, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 436, 'MON', 2, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 363, 'MON', 22, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 358, 'THU', 8, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 595, 'MON', 11, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 556, 'THU', 16, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 317, 'FRI', 17, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 478, 'THU', 0, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 461, 'MON', 7, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 593, 'SUN', 0, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 498, 'MON', 3, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 453, 'WED', 3, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 452, 'WED', 4, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 560, 'THU', 3, 4);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 540, 'SAT', 11, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 592, 'WED', 8, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 504, 'SUN', 0, 1);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 543, 'THU', 6, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 395, 'THU', 3, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 436, 'THU', 9, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 499, 'THU', 0, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 576, 'FRI', 16, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 404, 'MON', 0, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 439, 'TUE', 8, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 529, 'WED', 21, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 397, 'WED', 4, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 444, 'WED', 15, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 354, 'SAT', 16, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 382, 'TUE', 8, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 478, 'FRI', 1, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 510, 'MON', 16, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 566, 'WED', 8, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 324, 'WED', 4, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 555, 'MON', 8, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 511, 'MON', 11, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 481, 'WED', 8, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 442, 'WED', 7, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 400, 'MON', 4, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 532, 'WED', 7, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 540, 'MON', 14, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 505, 'THU', 2, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 421, 'TUE', 8, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 570, 'MON', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 508, 'MON', 9, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 410, 'WED', 5, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 522, 'WED', 20, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 352, 'SUN', 18, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 302, 'SUN', 2, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 553, 'THU', 18, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 446, 'WED', 1, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 429, 'MON', 22, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 590, 'MON', 6, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 546, 'SAT', 2, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 472, 'WED', 17, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 372, 'MON', 0, 5);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 430, 'FRI', 7, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 552, 'THU', 6, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 306, 'MON', 10, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 421, 'WED', 3, 21);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 425, 'MON', 2, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 422, 'TUE', 3, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 474, 'FRI', 15, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 448, 'THU', 8, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 542, 'SAT', 13, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 446, 'TUE', 1, 8);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 480, 'TUE', 14, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 545, 'WED', 2, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 563, 'THU', 13, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 331, 'MON', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 324, 'TUE', 1, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 473, 'FRI', 1, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 415, 'WED', 8, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 514, 'WED', 4, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 479, 'WED', 17, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 599, 'THU', 5, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 306, 'WED', 8, 19);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 480, 'WED', 0, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 562, 'FRI', 0, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 570, 'TUE', 5, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 583, 'WED', 11, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 549, 'THU', 15, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 520, 'WED', 9, 17);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 438, 'MON', 4, 12);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 470, 'THU', 4, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 312, 'WED', 14, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 355, 'TUE', 15, 16);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 531, 'MON', 10, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 330, 'FRI', 7, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 561, 'TUE', 2, 7);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 377, 'WED', 7, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 555, 'WED', 2, 13);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 397, 'MON', 6, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 548, 'TUE', 8, 14);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 483, 'MON', 3, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 421, 'SAT', 5, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 407, 'MON', 8, 20);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 553, 'TUE', 17, 23);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 526, 'SUN', 3, 11);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 358, 'SUN', 12, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 474, 'WED', 13, 15);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 440, 'FRI', 7, 10);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 424, 'TUE', 0, 2);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 493, 'MON', 3, 9);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 335, 'MON', 17, 22);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 347, 'TUE', 2, 18);
INSERT INTO ppl.places_schedule( id_place, "day", "from", "until" ) VALUES ( 378, 'TUE', 12, 16);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 601, 'Kwidzyn', 'Jana i Jozefa Kotlarczykow', 365, 75754, 757467877252);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 602, 'Miastko', 'Na Mostkach', 36, 92683, 179432568709);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 603, 'Zabrze', 'inneMost Zwierzyniecki', 34, 92673, 540014094866);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 604, 'Nowy_Sacz', 'Mydlnicka', 384, 71159, 515653493161);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 605, 'Jastrzebie-Zdroj', 'Orla', 114, 17054, 503738552105);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 606, 'Zakopane', 'Litewska', 330, 12233, 727941108901);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 607, 'Szczecin', 'Zimorodkow', 403, 72931, 349990575182);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 608, 'Ilawa', 'dr. Tadeusza Kudlinskiego', 15, 82443, 783964745032);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 609, 'Pilawa_Gorna', 'Bronowicka', 405, 23610, 297320051732);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 610, 'Aleksandrow_Kujawski', 'Skrajna', 472, 93211, 928372610484);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 611, 'Lubawa', 'Do Przystani', 77, 78744, 897450208458);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 612, 'Klodzko', 'Krzyzowka', 455, 10304, 299801441912);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 613, 'Karpacz', 'Nawigacyjna', 499, 76277, 895490703312);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 614, 'Chrzanow', 'Migdalowa', 270, 96058, 495519028381);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 615, 'Goleniow', 'Przeskok', 488, 84127, 453588797054);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 616, 'Olesnica', 'Jaskolcza', 80, 26981, 995258802152);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 617, 'Nowa_Sol', 'Lisia', 274, 39348, 893350718616);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 618, 'Kornik', 'dr. Tadeusza Kudlinskiego', 47, 77638, 354834045444);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 619, 'Nowy_Dwor_Mazowiecki', 'Strzelnica', 222, 35237, 323042833121);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 620, 'Czechowice-Dziedzice', 'innezrodlo im. Jerzego Setmajera', 207, 30710, 634207851299);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 621, 'Zgierz', 'Rzepichy', 143, 82685, 560663906460);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 622, 'Sieradz', 'Podluzna', 85, 78328, 169486762556);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 623, 'Miedzychod', 'Dzielna', 244, 80323, 136144246217);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 624, 'Wieruszow', 'Skladowa', 471, 90376, 714760828811);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 625, 'Debica', 'Kujawska', 445, 57163, 505660663939);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 626, 'Pleszew', 'Groszkowa', 268, 14627, 419096931124);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 627, 'lodz', 'Legnicka', 286, 41212, 371659459568);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 628, 'Lipno', 'Boleslawa Wallek-Walewskiego', 127, 53218, 212890611631);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 629, 'Gluszyca', 'Dolina', 345, 91591, 414767736660);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 630, 'Ostrow_Wielkopolski', 'Narcyzowa', 480, 61341, 723086349125);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 631, 'Mogilno', 'Fiszera', 167, 60195, 282269563543);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 632, 'Jastrzebie-Zdroj', 'al.Kasztanowa', 130, 61457, 130696330815);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 633, 'Jozefow', 'Wladyslawa Syrokomli', 210, 90787, 273968199558);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 634, 'Bukowno', 'Leopolda Staffa', 63, 29305, 309101554679);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 635, 'Szczecinek', 'Antoniego Augustynka-Wichury', 374, 39100, 134598623313);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 636, 'Konin', 'Adama Vetulaniego', 234, 23331, 715638663901);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 637, 'swiebodzice', 'smiala', 85, 71275, 624859137888);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 638, 'Tarnow', 'Wladyslawa Raczkiewicza', 226, 94279, 850106730920);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 639, 'Zary', 'Przesmyk', 142, 60559, 655773312184);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 640, 'Skierniewice', 'Wladyslawa Stanislawa Reymonta', 251, 36310, 685525977207);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 641, 'Miasteczko_slaskie', 'Stanislawa Witkiewicza', 256, 83203, 346461759421);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 642, 'Sulejow', 'Arsenal', 249, 40184, 732515880788);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 643, 'Opole_Lubelskie', 'Koziarowka', 168, 74969, 999297392082);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 644, 'Karpacz', 'Torunska', 160, 65470, 528114248810);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 645, 'Brzozow', 'Iwona Odrowaza', 421, 74511, 182453153661);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 646, 'Bychawa', 'Kujawska', 27, 15150, 872127452962);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 647, 'Aleksandrow_Kujawski', 'Raclawicka', 449, 50529, 604451100085);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 648, 'Tomaszow_Lubelski', 'Wadol', 366, 57971, 543890342590);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 649, 'Wlodawa', 'Witolda Budryka', 279, 66101, 852725924797);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 650, 'Strzelce_Krajenskie', 'Adolfa Szyszko-Bohusza', 110, 71999, 264644068620);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 651, 'Ustron', 'Emaus', 24, 87839, 125475361342);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 652, 'Lubawa', 'Droznicka', 52, 55370, 265941080901);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 653, 'Pajeczno', 'Boleslawa Czerwienskiego', 278, 54859, 898046343675);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 654, 'Chelmno', 'Mydlnicka', 293, 75711, 243205201699);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 655, 'Tuszyn', 'Cieszynska', 142, 85053, 949477286993);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 656, 'Wyszkow', 'Krzywy Zaulek', 354, 49109, 621766875346);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 657, 'Ilawa', 'Tadeusza Boya-zelenskiego', 470, 24714, 107069118365);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 658, 'Opole_Lubelskie', 'Na Blonie', 39, 69212, 616629122129);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 659, 'Gryfino', 'Gzymsikow', 130, 44318, 105293747370);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 660, 'Naklo_nad_Notecia', 'Wloczkow', 424, 50943, 798480929546);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 661, 'Piaseczno', 'Legnicka', 248, 84602, 366080698810);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 662, 'Orzesze', 'Lucjana Rydla', 71, 15353, 678955997554);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 663, 'Walcz', 'Na Blonie', 319, 85349, 889475799978);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 664, 'Opoczno', 'Zaborska', 323, 49282, 635042245759);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 665, 'Opalenica', 'Krancowa', 337, 56231, 353580928764);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 666, 'Czerwionka-Leszczyny', 'Ksiecia Jozefa', 376, 37389, 113402915672);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 667, 'Klodawa', 'Ludomira Benedyktowicza', 79, 67358, 400107419607);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 668, 'Staszow', 'Skalna', 224, 74472, 793002312299);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 669, 'Piotrkow_Trybunalski', 'Urodzajna', 198, 43788, 974176473756);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 670, 'Tuszyn', 'Kazimierza Herwina-Piatka', 75, 32405, 161986230828);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 671, 'Sochaczew', 'Bratyslawska', 4, 76303, 174347927699);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 672, 'Jaworzno', 'inneMost Zwierzyniecki', 445, 70906, 850702882641);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 673, 'Stargard', 'Zloty Rog', 444, 82428, 989247419489);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 674, 'Elblag', 'Zarzecze', 140, 12190, 795836598861);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 675, 'Brzesko', 'Zgody', 371, 50416, 271388025837);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 676, 'Jaroslaw', 'Insurekcji Kosciuszkowskiej', 480, 11490, 124943869496);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 677, 'Brzeziny', 'bp. Jozefa Gawliny', 88, 32240, 155461984364);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 678, 'Prabuty', 'Zakamycze', 349, 13863, 200625761103);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 679, 'Znin', 'Glogowiec', 420, 23339, 828935409603);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 680, 'Kety', 'Ojca Eugeniusza Krajewskiego', 436, 80506, 248847288318);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 681, 'Poniatowa', 'Mazowiecka', 305, 19680, 826452390429);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 682, 'Orneta', 'Waleczna', 33, 98191, 786544683010);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 683, 'Mogilno', 'Turowiec', 448, 70808, 848396487798);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 684, 'Krakow', 'Glogowa', 70, 54180, 424976172573);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 685, 'Zgorzelec', 'Zygmunta Glogera', 1, 78994, 207828312880);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 686, 'Piechowice', 'Dworna', 225, 66993, 342916169607);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 687, 'Makow_Mazowiecki', 'Polna', 96, 53832, 231596737209);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 688, 'Barlinek', 'os.Krowodrza Gorka', 11, 94363, 928722799774);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 689, 'Pobiedziska', 'Ignacego Sewera', 231, 72036, 581192630777);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 690, 'Sobotka', 'Cyganska', 176, 32272, 483795618616);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 691, 'Bydgoszcz', 'Olszanicka', 7, 58552, 500182772687);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 692, 'Nowy_Targ', 'Morelowa', 215, 69674, 558564461237);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 693, 'Gdynia', 'Kolowa', 66, 86050, 628937283338);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 694, 'Bilgoraj', 'Waclawa Nalkowskiego', 369, 18802, 972807123204);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 695, 'Kwidzyn', 'Adolfa Szyszko-Bohusza', 359, 70576, 877775097646);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 696, 'lancut', 'Wincentego Wodzinowskiego', 236, 40159, 916990244989);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 697, 'Klodzko', 'Porzecze', 133, 25507, 598335607718);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 698, 'Poreba', 'Pod Sulnikiem', 201, 88780, 972982441164);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 699, 'Skarzysko-Kamienna', 'Feliksa Radwanskiego', 470, 79479, 404491358943);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 700, 'Wodzislaw_slaski', 'Starego Wiarusa', 483, 76070, 358735907704);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 701, 'Bystrzyca_Klodzka', 'Starego Debu', 27, 65858, 940810697197);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 702, 'Gliwice', 'Bronowicka', 337, 71837, 540514348463);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 703, 'Mszana_Dolna', 'Antoniego Augustynka-Wichury', 402, 37362, 283635668753);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 704, 'Prabuty', 'Oswiecimska', 398, 48722, 961419557888);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 705, 'Nowogard', 'Rolnicza', 335, 44229, 750247368082);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 706, 'Wlodawa', 'Pod Sulnikiem', 401, 36226, 270106046601);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 707, 'Krakow', 'Okrezna', 100, 93907, 531150107337);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 708, 'Kamienna_Gora', 'Gabrieli Zapolskiej', 169, 71550, 957754231723);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 709, 'Miedzyrzecz', 'smiala', 363, 34457, 802829064089);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 710, 'Wrzesnia', 'Henryka Sienkiewicza', 178, 57321, 603991845927);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 711, 'Pleszew', 'Jacka Malczewskiego', 224, 79193, 309850796476);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 712, 'Gostyn', 'Wesele', 32, 62469, 718219257793);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 713, 'Makow_Mazowiecki', 'Eljasza Walerego Radzikowskiego', 139, 91679, 670118969985);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 714, 'Stalowa_Wola', 'parkKrakowski', 321, 77705, 436724908431);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 715, 'Wolomin', 'Kolaczy', 371, 54671, 682521096573);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 716, 'Glowno', 'Szarotki', 69, 94427, 188405056741);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 717, 'Bialogard', 'skwerSkwer Konika Zwierzynieckiegododane', 497, 24677, 636967784250);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 718, 'Grojec', 'bulw.Bulwar Rodla', 237, 59053, 783471903378);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 719, 'Myslowice', 'Edwarda Bzymka-Strzalkowskiego', 377, 12201, 710610918094);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 720, 'Ustrzyki_Dolne', 'Fiszera', 471, 99650, 466203225612);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 721, 'Hel', 'Tadeusza Ochlewskiego', 457, 72596, 506319536794);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 722, 'Pelplin', 'Boleslawa Prusa', 241, 79792, 130823589948);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 723, 'leba', 'Urzednicza', 363, 60786, 758591288619);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 724, 'Dzierzgon', 'Wodociagowa', 287, 64486, 650594770556);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 725, 'Nowa_Sol', 'Jana i Jozefa Kotlarczykow', 227, 76320, 814099037608);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 726, 'Naklo_nad_Notecia', 'Przegon', 480, 74096, 156025826557);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 727, 'Dlugoleka', 'Franciszka Kowalskiego', 87, 10759, 437939513925);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 728, 'Terespol', 'Przesmyk', 350, 15995, 405997769808);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 729, 'Zamosc', 'Papiernicza', 489, 23773, 809104055972);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 730, 'Pruszkow', 'al.Modrzewiowa', 174, 77132, 483053883650);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 731, 'Pajeczno', 'Wioslarska', 21, 35544, 939281106927);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 732, 'Zielona_Gora', 'Przyszlosci', 326, 58461, 563966475292);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 733, 'Miedzychod', 'Szopkarzy', 160, 82735, 375187517152);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 734, 'Kowary', 'Jadwigi Majowny', 229, 88707, 242098550505);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 735, 'Hajnowka', 'Mahatmy Gandhiego', 406, 91876, 756389957723);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 736, 'Ledziny', 'Tadeusza Boya-zelenskiego', 131, 57866, 627491991945);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 737, 'Mosina', 'Kasztelanska', 19, 64386, 386004021867);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 738, 'Jelenia_Gora', 'Dworna', 102, 22447, 212801219682);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 739, 'Koszalin', 'gen. Kiwerskiego', 284, 40328, 901549416346);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 740, 'Pajeczno', 'Polnych Kwiatow', 355, 75017, 752235729678);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 741, 'Ropczyce', 'prof. Teodora Spiczakowa', 62, 25691, 986208013448);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 742, 'Wolbrom', 'Wincentego Oszustowskiego', 346, 80476, 460970177397);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 743, 'Bierutow', 'Mlodej Polski', 235, 79387, 848202836767);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 744, 'Sulkowice', 'sw. Bronislawy', 357, 13520, 553734760015);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 745, 'Krynica', 'Zaborska', 59, 19028, 187229011450);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 746, 'Ostrow_Wielkopolski', 'Na Bloniach', 297, 14193, 223529672458);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 747, 'Gryfice', 'Kreta', 226, 17936, 113872431332);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 748, 'Grodzisk_Wielkopolski', 'Lisia', 152, 77058, 129949447194);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 749, 'Wagrowiec', 'Grazyny', 126, 72979, 450613115339);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 750, 'Milicz', 'al.Kijowska', 70, 20182, 557097758256);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 751, 'Paslek', 'Tadeusza Kasprzyckiego', 116, 22975, 214001430818);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 752, 'Otwock', 'parkKrowoderski', 456, 11565, 494481332865);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 753, 'Busko-Zdroj', 'pl.Nowowiejski', 172, 89101, 807407513363);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 754, 'Bielsk_Podlaski', 'Panoramiczna', 215, 96587, 341858723617);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 755, 'Krapkowice', 'Strzelnica', 402, 31694, 575675329600);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 756, 'Klobuck', 'al.Panienskich Skal', 371, 41751, 887371048689);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 757, 'Malbork', 'Wincentego Weryhy-Darowskiego', 332, 35650, 828179040387);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 758, 'Bolkow', 'Winowcow', 243, 59302, 424290223595);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 759, 'Bielawa', 'Pod Skala', 377, 79579, 799103619165);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 760, 'Slupsk', 'Maurycego Beniowskiego', 32, 98245, 967592829937);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 761, 'Glogow', 'Murarska', 427, 10748, 314994824354);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 762, 'Skwierzyna', 'Pasternik', 59, 99245, 789824755087);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 763, 'Zambrow', 'Gabriela Narutowicza', 321, 19166, 994294171594);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 764, 'Parczew', 'Brzegowa', 385, 41076, 694194917872);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 765, 'Nowy_Dwor_Gdanski', 'Za Sklonem', 160, 44288, 634057786348);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 766, 'Tychy', 'Jadwigi z lobzowa', 390, 31694, 579669787108);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 767, 'srem', 'Zaszkolna', 295, 57223, 200528501760);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 768, 'Szczytno', 'Starego Wiarusa', 222, 67621, 171491395187);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 769, 'Inowroclaw', 'Brzegowa', 94, 99960, 245676474254);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 770, 'Radzyn_Podlaski', 'al.Modrzewiowa', 247, 96127, 504780450512);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 771, 'Rawicz', 'Jablonkowska', 11, 81728, 417046547506);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 772, 'Rawa_Mazowiecka', 'Matki Pauli Zofii Tajber', 89, 38299, 767793345457);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 773, 'Sulechow', 'Krzyzowka', 51, 96264, 216863690993);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 774, 'Szczawnica', 'Generala Stanislawa Sosabowskiego', 168, 30386, 464372747544);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 775, 'Niepolomice', 'Ludwika Krzywickiego', 86, 13787, 834775634832);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 776, 'Pyrzyce', 'Chocimska', 329, 51269, 116874658410);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 777, 'Lubaczow', 'Oswiecimska', 266, 48063, 821094946673);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 778, 'Nisko', 'Ludwika Muzyczki', 129, 16059, 846385487860);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 779, 'Boleslawiec', 'Hoza', 291, 13814, 760989014900);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 780, 'Koscian', 'Na Zielonki', 171, 98173, 376698976819);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 781, 'Brzeg', 'Eljasza Walerego Radzikowskiego', 168, 18351, 139622531209);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 782, 'Dabrowa_Tarnowska', 'Kiejstuta zemaitisa', 341, 62986, 972943019596);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 783, 'Chelmno', 'Siewna', 161, 85788, 771455106649);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 784, 'Kielce', 'Jasna', 23, 56592, 650892215464);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 785, 'Chelmek', 'Jesionowa', 276, 83203, 879228190078);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 786, 'Radzyn_Podlaski', 'Kukulcza', 441, 19510, 955141037631);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 787, 'Gostyn', 'Josepha Conrada', 26, 38104, 607939353085);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 788, 'Mikolow', 'Rzeczna', 1, 21258, 775026250726);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 789, 'Legnica', 'gen. Augusta Fieldorfa-Nila', 76, 61636, 512411362701);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 790, 'Turek', 'ks. Jozefa Meiera', 116, 51661, 738371325665);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 791, 'Koronowo', 'rtm. Witolda Pileckiego', 204, 84694, 562846548277);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 792, 'Siechnice', 'Adama Chmiela', 90, 85349, 431987402027);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 793, 'Chodziez', 'Bliska', 346, 46033, 227747813817);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 794, 'Mogilno', 'Pielegniarek', 97, 38901, 951922019426);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 795, 'Kety', 'Juliusza Lea', 190, 55468, 757341891705);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 796, 'Strzyzow', 'Warmijska', 371, 45182, 388534274000);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 797, 'Chelm', 'Wincentego Weryhy-Darowskiego', 131, 28142, 450517063579);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 798, 'Czarne', 'Tadeusza Rogalskiego', 193, 26180, 224733345779);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 799, 'Bialogard', 'Bielanska', 237, 50805, 324465338511);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 800, 'Kozienice', 'Eugeniusza Kwiatkowskiego', 276, 56500, 738607464595);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 801, 'laziska_Gorne', 'Stawowa', 73, 50245, 556685027920);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 802, 'Hajnowka', 'Jordanowska', 35, 52127, 592959369808);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 803, 'Hajnowka', 'Kaspra zelechowskiego', 268, 50930, 854554000061);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 804, 'Lidzbark', 'Junacka', 2, 48220, 198035068948);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 805, 'Lubawka', 'Mietowa', 488, 71055, 656941830092);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 806, 'Miedzyrzecz', 'Feliksa Kopery', 132, 20987, 904379777654);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 807, 'Bychawa', 'Kadrowki', 1, 97248, 246713836345);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 808, 'lobez', 'Okrag', 443, 39966, 119985343023);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 809, 'Szczecin', 'Starowolska', 448, 31108, 371732724151);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 810, 'Prudnik', 'Wernyhory', 496, 71548, 119726240677);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 811, 'Czeladz', 'Balicka', 101, 89457, 837131773360);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 812, 'Miasteczko_slaskie', 'Tadeusza Ochlewskiego', 293, 23019, 690849658555);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 813, 'Katy_Wroclawskie', 'Ojcowska', 230, 33000, 653083795673);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 814, 'Knurow', 'Uboczna', 155, 19789, 521631664539);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 815, 'Krosno', 'Wojtowska', 75, 59135, 842696094594);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 816, 'Szamotuly', 'Kolo Bialuchy', 341, 70414, 522196000650);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 817, 'Stargard', 'Przyszlosci', 272, 97692, 334511656550);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 818, 'Nowy_Dwor_Gdanski', 'Aleksandra Prystora', 194, 23165, 368180629188);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 819, 'Marki', 'Wincentego Weryhy-Darowskiego', 410, 67854, 466693116384);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 820, 'Nysa', 'Turystyczna', 483, 20834, 776015436753);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 821, 'Kartuzy', 'Jozefa Friedleina', 291, 59252, 406420733207);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 822, 'Pila', 'Proszowicka', 204, 43623, 969933775159);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 823, 'Lubliniec', 'rondoOfiar Katynia', 284, 25392, 362273961795);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 824, 'Opole', 'os.Witkowice Nowe', 456, 92661, 747690630344);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 825, 'Pieszyce', 'Lazurowa', 394, 26936, 521128696484);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 826, 'Kluczbork', 'rtm. Zbigniewa Dunin-Wasowicza', 476, 73205, 326817962822);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 827, 'Kostrzyn', 'al.Sosnowa', 388, 41559, 338936508876);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 828, 'Minsk_Mazowiecki', 'Jana Piwnika "Ponurego"', 460, 39130, 283947966020);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 829, 'Sochaczew', 'Malownicza', 429, 25310, 129025085453);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 830, 'Klodawa', 'zwirowa', 157, 50900, 534419561074);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 831, 'Solec_Kujawski', 'Zaskale', 91, 63342, 527442751083);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 832, 'Przeworsk', 'Wiedenska', 7, 72807, 131511679174);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 833, 'Starachowice', 'abp. Zygmunta Szczesnego Felinskiego', 408, 40204, 135355636802);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 834, 'Kutno', 'Henryka Reymana', 234, 91851, 457986536251);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 835, 'Grudziadz', 'Jerzego Szablowskiego', 339, 77625, 789393110011);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 836, 'Milicz', 'Cichy Kacik', 107, 77889, 696260146718);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 837, 'Kozy', 'pl.Teodora Axentowicza', 176, 20755, 345738464585);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 838, 'Kutno', 'os.Wolfganga Amadeusa Mozarta', 243, 60370, 976840495869);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 839, 'Konskie', 'Romana Ingardena', 259, 78536, 469104631275);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 840, 'Czeladz', 'Mackowa Gora', 272, 61679, 442392053586);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 841, 'lazy', 'Ludwika Solskiego', 468, 75532, 537756432906);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 842, 'Grodzisk_Wielkopolski', 'Kiejstuta zemaitisa', 372, 26337, 521919075511);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 843, 'Cieszyn', 'Jozefa Becka', 485, 47679, 737490975737);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 844, 'Jedrzejow', 'Eugeniusza Romera', 204, 72483, 776441947357);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 845, 'Kowary', 'Stanislawa Tondosa', 249, 13782, 955833550613);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 846, 'Wschowa', 'Dworna', 337, 30523, 764813086794);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 847, 'Szamotuly', 'Misjonarska', 246, 54908, 370317925552);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 848, 'Nowogard', 'Marcina Borelowskiego "Lelewela"', 97, 19718, 541941280172);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 849, 'Zuromin', 'Krucza', 104, 11199, 977090932901);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 850, 'Wieruszow', 'Bularnia', 360, 98125, 667933507171);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 851, 'Jawor', 'Powstania Styczniowego', 192, 67143, 536508825055);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 852, 'Pinczow', 'Na Nowinach', 13, 63459, 197104062646);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 853, 'Znin', 'Stanislawa Kasznicy', 120, 83347, 936991911877);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 854, 'Sulkowice', 'Misjonarska', 400, 41367, 872336584556);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 855, 'Bytow', 'Jodlowa', 353, 42761, 546100157819);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 856, 'Wozniki', 'Wojciecha Halczyna', 495, 44883, 160122138106);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 857, 'Bialogard', 'Legnicka', 472, 78788, 935323541208);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 858, 'leba', 'Stanislawa Konarskiego', 430, 31421, 382255959914);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 859, 'lomianki', 'Kawiory', 478, 59514, 521998149176);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 860, 'Jedrzejow', 'Wilczy Stok', 302, 86094, 184488158764);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 861, 'Sztum', 'Mydlnicka', 484, 18333, 565425389020);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 862, 'Ziebice', 'Piotra Borowego', 5, 87091, 303534634948);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 863, 'Tczew', 'Jodlowa', 336, 94660, 814863441172);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 864, 'Lubaczow', 'Maurycego Beniowskiego', 450, 47689, 570220545055);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 865, 'Gizycko', 'Feliksa Konecznego', 152, 96427, 722564592844);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 866, 'Bierutow', 'Wioslarska', 183, 52716, 906919270663);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 867, 'Sulechow', 'Zaskale', 299, 96982, 676251186771);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 868, 'Chocianow', 'Krucza', 208, 95065, 325947267199);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 869, 'Szamotuly', 'Stanislawa Kostki Potockiego', 46, 75627, 150969532125);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 870, 'Wolsztyn', 'Feliksa Szlachtowskiego', 472, 70559, 116573958364);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 871, 'Pelplin', 'Gleboka', 276, 11734, 741559907736);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 872, 'Myslowice', 'Zygmunta Wyrobka', 79, 99974, 971512125474);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 873, 'Koscian', 'inneKopiec Kosciuszki', 169, 45337, 283272741966);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 874, 'Gryfice', 'Wladyslawa Podkowinskiego', 428, 33611, 769190002564);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 875, 'Nisko', 'Belwederczykow', 230, 41187, 751393391617);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 876, 'Nowy_Targ', 'Polnocna', 427, 82091, 811099207859);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 877, 'Rydultowy', 'Josepha Conrada', 133, 31576, 310977020750);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 878, 'lask', 'Jaskolcza', 300, 73140, 749712972307);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 879, 'Bartoszyce', 'Jozefa Herzoga', 133, 45441, 657615432314);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 880, 'Brzeg_Dolny', 'al.Sosnowa', 15, 96501, 412828330254);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 881, 'Skierniewice', 'Lisia', 124, 35384, 900046604549);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 882, 'Koluszki', 'Wladyslawa Anczyca', 260, 11640, 385977280484);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 883, 'Ledziny', 'Junacka', 294, 90388, 418678096910);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 884, 'Koluszki', 'Jozefa Kmietowicza', 390, 26892, 702356220578);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 885, 'Przasnysz', 'Dziewanny', 311, 73666, 931839362077);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 886, 'Siemiatycze', 'Tadeusza Kasprzyckiego', 149, 95828, 176433986101);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 887, 'Olsztynek', 'Ryszarda Berwinskiego', 58, 32359, 887730012960);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 888, 'Piechowice', 'al.Adama Mickiewicza', 435, 90991, 915225315345);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 889, 'Bochnia', 'zwirowa', 352, 67773, 306333321781);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 890, 'Bukowno', 'Berberysowa', 453, 36310, 432676216638);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 891, 'Glogow', 'Pamietna', 294, 81856, 136561888552);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 892, 'Wlodawa', 'pl.Nowowiejski', 157, 64322, 155533960656);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 893, 'Tuszyn', 'Stawowa', 253, 81905, 691964709762);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 894, 'Trzcianka', 'Lazurowa', 333, 20143, 641611406802);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 895, 'Glucholazy', 'Mlodej Polski', 126, 41988, 438622490964);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 896, 'Radom', 'Chabrowa', 309, 80694, 476958897621);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 897, 'Wlodawa', 'Wlodzimierza Puchalskiego', 229, 25576, 744382867413);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 898, 'Konstancin-Jeziorna', 'Kreta', 417, 10108, 490899480121);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 899, 'Klobuck', 'Tadeusza Wyrwy-Furgalskiego', 150, 10754, 955138438617);
INSERT INTO ppl.storages( id, city, street, house_number, postal_code, volume ) VALUES ( 900, 'Bogatynia', 'Chocimska', 444, 13033, 336243017445);
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 1, 'Roman', 'Michalski', '232229', 1948991452, 487305198, 'jftf@b-d-un.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 2, 'Artur', 'Wisniewski', null, null, 480882584, 'pvgg7@---k--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 3, 'Kazimiera', 'Wroblewski', 'hescin5', 610849826, 484889045, 'iips.opcwen@g---x-.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 4, 'Magdalena', 'Marciniak', '123456def', 53286715, 484618372, 'mtgq3@c-fs-k.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 5, 'Stanislaw', 'Borkowski', 'romeo1997', 1716279577, 484485983, 'mjck243@m--o--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 6, 'Agnieszka', 'Baranowski', 'stacey', 324768466, 486977123, 'nmpsj@----vb.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 7, 'Alicja', 'Jaworski', 'camila123', 902843160, 482777673, 'lesh.nfpe@qdlgu-.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 8, 'Barbara', 'Zalewski', null, null, 487599608, 'dbtk43@w-u---.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 9, 'Janusz', 'Kalinowski', null, null, 482192445, 'ewhm.wrrv@----w-.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 10, 'Edyta', 'Michalski', '7oss1am1', 1768772963, 489204139, 'xeakj9@v-ab-h.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 11, 'Henryk', 'Szewczyk', '9786775351', 1384195690, 488860557, 'jhpt1@-r-pqo.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 12, 'Robert', 'Michalski', 'gayatri45', 1613937925, 482220016, 'idon@bs--p-.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 13, 'Irena', 'Michalski', 'ritu01991', 968749031, 488838785, 'rkox2@pm-p-q.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 14, 'Tadeusz', 'Nowak', 'flash236', 1734358423, 484394655, 'aicj@-i-vsv.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 15, 'Jerzy', 'Bak', null, null, 483928764, 'ihog6@-h--as.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 16, 'Damian', 'Gorski', 'hakkinen', 1678515937, 488815007, 'vkll65@j----j.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 17, 'Jerzy', 'Sawicki', 'rahulproject3', 744779428, 482831489, 'hrhv5@--f---.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 18, 'Czeslaw', 'Bak', 'toledo13', 1048710205, 482478253, 'uttd@qc-ws-.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 19, 'Zdzislaw', 'Kaczmarek', null, null, 485935642, 'fpsyf.fxuju@b---y-.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 20, 'Rafal', 'Majewski', 'Owt2j17glU', 1804305905, 485118487, 'myec5@v--eyb.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 21, 'Justyna', 'Ostrowski', '23517153', 1927677104, 480772075, 'mbgz@-o--yq.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 22, 'Janina', 'Maciejewski', null, null, 480401603, 'jctg@-m-v--.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 23, 'Waldemar', 'Nowak', 'sonyericssonz310i', 318109936, 486830675, 'vnou.cwkepl@-tv---.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 24, 'Mateusz', 'Rutkowski', 'dalesteyn', 971355902, 484507340, 'tzmpn@s--u--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 25, 'Marek', 'Zawadzki', 'vijay9524', 1206401873, 483545521, 'eujf644@-blvr-.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 26, 'Daniel', 'Kolodziej', 'palak333', 1780390841, 483018438, 'hidc06@--w-wh.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 27, 'Krzysztof', 'Szymanski', 'harsha9838223910', 720234895, 481254340, 'pbgw@-ork-w.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 28, 'Natalia', 'Sikorski', 'sweet12345', 889421171, 483497419, 'jzph@-cz-tu.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 29, 'Katarzyna', 'Nowakowski', 'anas586787', 1539328698, 486923181, 'muxm@pw-oxc.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 30, 'Stanislaw', 'Jablonski', '282096j', 967088503, 480341070, 'lllq@x-bvg-.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 31, 'Tadeusz', 'Wisniewski', 'windows1', 2127736795, 480384429, 'nnni694@g-ifw-.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 32, 'Tomasz', 'Wysocki', 'u209050', 1082593066, 486840429, 'vzor@y-xj-r.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 33, 'Zdzislaw', 'Dudek', '22587946133', 1844398615, 485831768, 'wprs@--ulkd.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 34, 'Beata', 'Mazurek', 'sannec', 1790854556, 488334518, 'ssjjf3@-ohx-h.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 35, 'Marian', 'Maciejewski', 'nurul1981', 1017195237, 486175258, 'ljdt3@-j----.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 36, 'Alicja', 'Sikora', '8059644984', 1412873037, 486505844, 'ujuu@-pej--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 37, 'Jadwiga', 'Szczepanski', 'jessintha', 1345876718, 482738464, 'yodi402@r-nmj-.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 38, 'Jacek', 'Baran', 'l8rR9jn7iU', 2094808833, 489992192, 'uecm278@hysi-k.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 39, 'Natalia', 'Krawczyk', 'a254252b', 1797931491, 484756825, 'jspt.hfboc@-----v.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 40, 'Jacek', 'Szewczyk', 'Cm33921578', 196029808, 480916146, 'kpptg383@--mnpb.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 41, 'Damian', 'Michalski', 'gorrisimple', 653546486, 488579193, 'wmvk@g-k-lz.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 42, 'Beata', 'Sikora', 'wd233633', 1696866454, 485605012, 'ival@---p--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 43, 'Artur', 'Olszewski', 'Manith@123#', 806239115, 484932114, 'ntpu@------.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 44, 'Anna', 'Czarnecki', null, null, 488363621, 'xtbgm61@jc--wf.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 45, 'Jozef', 'Szymanski', 'breanne', 1453298028, 481829378, 'jsgy5@dgsw--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 46, 'Piotr', 'Marciniak', 'wisky1979', 1694318720, 480283060, 'tkjo@a-sqmv.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 47, 'Renata', 'Sokolowski', '20yuvi91Z!', 964389720, 481843790, 'qxqqf@m-at-x.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 48, 'Tomasz', 'Szulc', 'seattle12', 530692573, 481591169, 'hzxh@-wab-c.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 49, 'Genowefa', 'Kowalczyk', 'ttpl@123', 318304442, 485797409, 'klwg.vszj@-sh-i-.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 50, 'Marcin', 'Rutkowski', '023855', 581144195, 480078546, 'fied.qzsx@-wz-ft.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 51, 'Karolina', 'Malinowski', 'saprissa', 2104357929, 485740323, 'woeo@-w----.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 52, 'Agnieszka', 'Majewski', null, null, 480058819, 'uylr@-fcf--.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 53, 'Wieslaw', 'Wojciechowski', 'xtownlove', 1646299576, 487760898, 'pvzs10@ojfo--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 54, 'Anna', 'Szczepanski', 'mandan2k', 2000389839, 482956452, 'btznr@---p-e.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 55, 'Andrzej', 'Czarnecki', null, null, 486432844, 'osvl3@---r-b.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 56, 'Wladyslaw', 'Szymczak', '1rotomotor1', 529101544, 488771952, 'fsjb@swg--e.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 57, 'Kamil', 'Krawczyk', 'dev@ng', 1158526307, 485944913, 'roaw.oxyk@jkqv--.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 58, 'Daniel', 'Malinowski', 'w1fs4v', 1719313786, 482817566, 'bibi52@---t-i.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 59, 'Czeslaw', 'Wysocki', 'chelizadan12', 210034349, 480148921, 'mqpy79@-m-mqz.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 60, 'Elzbieta', 'Baran', 'prabitha', 1735123306, 483334527, 'qnrl60@p--i-r.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 61, 'Monika', 'Sokolowski', null, null, 487700025, 'qdied.zjewzp@-r----.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 62, 'lukasz', 'Witkowski', 'cool', 1031313272, 489713071, 'ryjt634@-----p.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 63, 'Iwona', 'Nowicki', 'ppppp', 1576521936, 480688736, 'vpvv.tely@k-c--j.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 64, 'Marek', 'Zalewski', 'seaweed123', 931887446, 480826088, 'umgis@v-wv-u.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 65, 'Jadwiga', 'Wojciechowski', 'happy_star27', 1373173900, 489880526, 'swsf6@vnnbd.o-iok-.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 66, 'Marcin', 'Kazmierczak', '9375875120', 625805014, 487731517, 'khyi@-cox-u.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 67, 'Marta', 'Kalinowski', 'mf106900', 1829503477, 481904311, 'wwml9@r-ype-.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 68, 'Jakub', 'Kowalczyk', null, null, 480277154, 'imts@-----s.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 69, 'Damian', 'Brzezinski', 'john4816', 604869432, 480616244, 'qxoj.wmjc@--b---.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 70, 'Urszula', 'Wojciechowski', 'dlfowfzcmrxum', 1251995926, 481118064, 'kmgv@lg--ly.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 71, 'Maria', 'Zalewski', '8898239732', 819377368, 488099282, 'vebe66@vc----.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 72, 'Leszek', 'Sawicki', null, null, 481653859, 'vtsk343@-nwfbd.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 73, 'Artur', 'Adamski', 'benipal', 1487734309, 488071692, 'plfb6@--rj--.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 74, 'Izabela', 'Jakubowski', 'vampire98x', 423986369, 488315516, 'mishy@w-gd--.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 75, 'Elzbieta', 'Andrzejewski', 'jomar235', 2139161008, 483610846, 'tvwv@yxd-q-.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 76, 'Roman', 'Malinowski', '95371293', 741448024, 481198092, 'xhvh.rkzad@s-----.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 77, 'Henryk', 'Przybylski', 'waladito', 1211828256, 482699068, 'xlnw@--l-ow.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 78, 'Miroslaw', 'Wisniewski', 'picci', 433525975, 481462186, 'lppi.bmlfv@p-g---.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 79, 'Sebastian', 'Maciejewski', null, null, 489208030, 'xogs@g-pvsw.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 80, 'Marek', 'Krawczyk', null, null, 485346584, 'kojr@giet-m.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 81, 'Janina', 'Glowacki', 'thurped1', 143064377, 484264395, 'lvyt@h-rc-d.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 82, 'Irena', 'Zajac', 'suresh1234', 567143928, 484446475, 'lrug453@-blc--.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 83, 'Jolanta', 'Tomaszewski', null, null, 485095160, 'rxws7@qu-eyo.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 84, 'Mateusz', 'Maciejewski', 'simran143', 2068491577, 485877080, 'pvfg@------.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 85, 'Beata', 'Laskowski', 'jesus1987', 1878046347, 489697856, 'atxm@v--t-q.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 86, 'Grazyna', 'Gajewski', '036538817', 1297716046, 489077668, 'dynwu4@--r-nu.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 87, 'Maria', 'Wisniewski', '880522095069', 2010256746, 485537062, 'ionc@-y---n.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 88, 'Maria', 'Krajewski', 'jlh2332', 1551391347, 489699804, 'fybx5@nho---.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 89, 'Sylwia', 'Wroblewski', '78692', 1476452632, 483383237, 'tvdl.vrurs@e-on-y.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 90, 'Jan', 'Szymczak', 'y6wp8f24', 1655657808, 482874843, 'cdxn4@----iv.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 91, 'Marian', 'Wieczorek', '36037834', 189367377, 489571327, 'xubg@-ic--t.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 92, 'Przemyslaw', 'Szczepanski', 'majure', 696909558, 487224970, 'wckt@-iyn--.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 93, 'Marianna', 'Wilk', 'ben01ben', 242962476, 481890067, 'cjcm@-hg--a.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 94, 'Elzbieta', 'Adamczyk', 'itla1234', 346071680, 484790556, 'iglcq@en-y--.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 95, 'Marzena', 'Marciniak', 'pikachu2881', 1887453251, 489530602, 'tltk@ct--t-.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 96, 'Malgorzata', 'Kucharski', 'warrior33', 644189511, 487809211, 'vbfv9@-j-dn-.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 97, 'Kazimiera', 'Michalak', '8439770959', 757621159, 485599909, 'efgfvv6@-c---l.com');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 98, 'Ryszard', 'Krajewski', 'UmoaT0NAI', 1747945137, 482331675, 'vqps40@p-wom-.net');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 99, 'Maciej', 'Szulc', 'Super123', 1660261750, 486869102, 'jkyq@---gyn.org');
INSERT INTO ppl.users( id, firstname, lastname, login, password_hash, phone_number, email ) VALUES ( 100, 'Andrzej', 'Kowalski', 'GopalProject2773', 1175713024, 486334655, 'dlnd317@--oj-g.com');
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 901, 219, 866, 811, 592);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 902, 30, 951, 349, 667);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 903, 123, 748, 346, 667);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 904, 122, 993, 837, 571);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 905, 62, 929, 459, 331);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 906, 10, 994, 762, 309);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 907, 99, 614, 864, 579);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 908, 197, 537, 320, 621);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 909, 290, 872, 867, 360);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 910, 213, 975, 961, 669);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 911, 1, 515, 406, 605);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 912, 45, 846, 937, 301);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 913, 289, 926, 999, 594);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 914, 47, 528, 677, 682);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 915, 281, 704, 984, 629);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 916, 166, 676, 410, 375);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 917, 284, 997, 684, 430);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 918, 273, 781, 365, 600);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 919, 281, 738, 610, 412);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 920, 146, 525, 589, 392);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 921, 119, 791, 500, 623);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 922, 274, 926, 418, 603);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 923, 104, 614, 641, 612);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 924, 47, 577, 960, 657);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 925, 88, 982, 923, 509);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 926, 110, 616, 675, 320);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 927, 151, 808, 700, 438);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 928, 259, 804, 477, 492);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 929, 34, 624, 783, 662);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 930, 161, 920, 972, 528);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 931, 231, 844, 533, 523);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 932, 175, 899, 482, 528);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 933, 197, 562, 593, 659);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 934, 12, 554, 387, 385);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 935, 47, 516, 823, 429);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 936, 228, 966, 628, 359);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 937, 113, 633, 418, 572);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 938, 187, 777, 615, 674);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 939, 41, 614, 498, 524);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 940, 263, 571, 650, 416);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 941, 208, 525, 657, 625);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 942, 135, 565, 648, 434);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 943, 241, 529, 534, 588);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 944, 1, 730, 523, 546);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 945, 1, 734, 889, 586);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 946, 255, 627, 337, 322);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 947, 156, 895, 929, 480);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 948, 7, 886, 812, 513);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 949, 223, 673, 690, 549);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 950, 211, 862, 453, 575);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 951, 42, 942, 333, 645);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 952, 82, 711, 371, 501);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 953, 144, 584, 689, 499);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 954, 22, 578, 709, 592);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 955, 163, 587, 498, 633);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 956, 183, 782, 796, 473);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 957, 173, 549, 959, 365);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 958, 286, 581, 354, 563);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 959, 61, 817, 480, 452);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 960, 82, 764, 894, 481);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 961, 187, 514, 646, 631);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 962, 57, 778, 398, 323);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 963, 55, 799, 746, 634);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 964, 0, 744, 752, 474);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 965, 3, 953, 771, 505);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 966, 205, 520, 826, 421);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 967, 48, 730, 409, 554);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 968, 145, 697, 613, 586);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 969, 53, 900, 577, 450);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 970, 146, 665, 404, 399);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 971, 162, 831, 305, 594);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 972, 37, 866, 922, 570);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 973, 292, 853, 921, 621);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 974, 39, 766, 496, 309);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 975, 73, 500, 819, 479);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 976, 61, 975, 972, 306);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 977, 118, 680, 422, 398);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 978, 253, 815, 788, 317);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 979, 65, 589, 887, 359);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 980, 121, 746, 911, 613);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 981, 129, 955, 726, 343);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 982, 284, 641, 345, 691);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 983, 69, 870, 927, 570);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 984, 156, 635, 397, 496);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 985, 266, 824, 300, 606);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 986, 116, 907, 615, 553);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 987, 11, 766, 433, 494);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 988, 81, 518, 314, 674);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 989, 177, 809, 623, 575);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 990, 33, 587, 546, 398);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 991, 196, 554, 309, 515);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 992, 68, 792, 601, 565);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 993, 35, 694, 392, 638);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 994, 297, 933, 816, 339);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 995, 195, 763, 802, 569);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 996, 175, 950, 630, 434);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 997, 295, 942, 485, 368);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 998, 288, 654, 581, 650);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 999, 62, 687, 958, 608);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1000, 79, 707, 977, 593);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1001, 112, 870, 336, 548);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1002, 108, 936, 772, 574);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1003, 139, 952, 862, 421);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1004, 263, 635, 857, 472);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1005, 100, 664, 768, 452);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1006, 87, 953, 862, 416);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1007, 132, 826, 439, 672);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1008, 15, 534, 536, 573);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1009, 151, 608, 808, 408);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1010, 55, 660, 548, 510);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1011, 299, 991, 612, 607);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1012, 191, 980, 344, 533);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1013, 189, 776, 494, 663);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1014, 83, 511, 750, 600);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1015, 272, 796, 819, 498);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1016, 102, 989, 396, 675);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1017, 152, 781, 996, 365);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1018, 79, 629, 631, 518);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1019, 147, 550, 828, 309);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1020, 35, 766, 959, 698);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1021, 128, 580, 941, 578);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1022, 41, 611, 637, 610);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1023, 92, 780, 808, 525);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1024, 163, 784, 701, 542);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1025, 215, 699, 617, 594);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1026, 148, 806, 973, 584);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1027, 288, 903, 421, 303);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1028, 4, 713, 789, 326);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1029, 62, 672, 985, 361);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1030, 107, 834, 543, 598);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1031, 51, 696, 328, 413);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1032, 72, 838, 757, 515);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1033, 164, 911, 524, 623);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1034, 240, 587, 620, 649);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1035, 166, 996, 868, 663);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1036, 32, 603, 482, 512);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1037, 176, 662, 325, 541);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1038, 155, 608, 442, 355);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1039, 236, 508, 698, 434);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1040, 158, 854, 797, 588);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1041, 209, 656, 385, 369);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1042, 108, 538, 785, 613);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1043, 61, 704, 628, 608);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1044, 132, 624, 799, 315);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1045, 76, 560, 382, 340);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1046, 209, 751, 715, 318);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1047, 233, 762, 616, 335);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1048, 52, 508, 512, 598);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1049, 67, 781, 475, 579);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1050, 209, 872, 397, 345);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1051, 294, 625, 462, 357);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1052, 278, 746, 938, 306);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1053, 241, 718, 540, 651);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1054, 221, 561, 600, 684);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1055, 250, 758, 862, 396);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1056, 27, 610, 819, 441);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1057, 48, 570, 765, 414);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1058, 131, 836, 639, 519);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1059, 191, 876, 828, 609);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1060, 96, 540, 344, 692);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1061, 2, 812, 898, 303);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1062, 196, 671, 382, 696);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1063, 189, 876, 749, 340);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1064, 111, 728, 839, 438);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1065, 62, 553, 523, 452);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1066, 273, 745, 847, 396);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1067, 264, 501, 712, 509);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1068, 91, 503, 611, 556);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1069, 212, 513, 431, 699);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1070, 242, 500, 645, 682);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1071, 217, 733, 314, 618);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1072, 128, 875, 423, 425);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1073, 152, 965, 371, 683);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1074, 16, 578, 534, 390);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1075, 296, 698, 419, 316);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1076, 41, 549, 760, 483);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1077, 45, 577, 672, 469);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1078, 178, 748, 480, 326);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1079, 213, 945, 707, 316);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1080, 284, 507, 538, 691);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1081, 247, 693, 535, 337);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1082, 152, 651, 777, 535);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1083, 37, 709, 525, 636);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1084, 196, 976, 331, 507);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1085, 185, 749, 685, 625);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1086, 212, 519, 918, 342);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1087, 144, 900, 336, 424);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1088, 79, 688, 300, 350);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1089, 29, 633, 405, 529);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1090, 19, 992, 461, 485);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1091, 185, 862, 585, 631);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1092, 177, 824, 425, 634);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1093, 8, 976, 784, 460);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1094, 85, 784, 435, 428);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1095, 177, 577, 565, 502);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1096, 157, 906, 819, 456);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1097, 21, 537, 483, 380);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1098, 77, 713, 570, 371);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1099, 22, 839, 631, 481);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1100, 84, 680, 686, 506);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1101, 203, 543, 402, 478);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1102, 192, 995, 348, 487);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1103, 84, 577, 675, 481);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1104, 106, 660, 302, 469);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1105, 181, 518, 983, 571);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1106, 46, 746, 484, 348);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1107, 254, 904, 301, 687);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1108, 110, 599, 920, 433);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1109, 106, 915, 928, 393);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1110, 169, 828, 995, 573);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1111, 179, 633, 441, 653);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1112, 72, 537, 709, 357);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1113, 87, 551, 622, 402);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1114, 5, 975, 517, 343);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1115, 262, 935, 404, 518);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1116, 247, 942, 777, 568);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1117, 223, 629, 680, 689);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1118, 161, 618, 571, 358);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1119, 126, 528, 873, 557);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1120, 192, 668, 976, 348);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1121, 112, 894, 706, 518);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1122, 291, 908, 586, 449);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1123, 81, 724, 698, 368);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1124, 258, 556, 938, 667);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1125, 218, 755, 852, 375);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1126, 237, 702, 967, 580);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1127, 266, 931, 843, 440);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1128, 253, 520, 944, 429);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1129, 13, 999, 901, 368);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1130, 130, 643, 519, 481);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1131, 137, 650, 427, 537);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1132, 101, 837, 308, 579);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1133, 258, 557, 872, 434);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1134, 89, 990, 627, 663);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1135, 270, 832, 774, 600);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1136, 25, 653, 449, 601);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1137, 18, 599, 546, 347);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1138, 167, 536, 640, 523);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1139, 229, 935, 663, 604);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1140, 78, 868, 680, 529);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1141, 128, 589, 955, 591);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1142, 179, 729, 821, 372);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1143, 299, 840, 979, 467);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1144, 290, 675, 585, 577);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1145, 18, 794, 648, 316);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1146, 189, 582, 772, 391);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1147, 175, 845, 644, 499);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1148, 165, 905, 434, 343);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1149, 170, 623, 445, 305);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1150, 163, 534, 803, 691);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1151, 198, 767, 569, 553);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1152, 60, 755, 317, 537);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1153, 272, 562, 467, 625);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1154, 299, 645, 860, 439);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1155, 73, 787, 794, 445);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1156, 212, 656, 994, 455);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1157, 74, 891, 961, 605);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1158, 262, 892, 902, 395);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1159, 212, 519, 969, 520);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1160, 256, 678, 722, 638);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1161, 101, 773, 978, 337);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1162, 233, 820, 306, 642);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1163, 182, 910, 770, 676);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1164, 64, 898, 930, 467);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1165, 94, 786, 512, 684);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1166, 263, 971, 555, 489);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1167, 7, 962, 718, 686);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1168, 249, 555, 591, 678);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1169, 135, 882, 364, 591);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1170, 79, 800, 961, 569);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1171, 110, 929, 685, 307);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1172, 173, 594, 409, 699);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1173, 139, 763, 536, 457);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1174, 39, 688, 899, 404);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1175, 53, 542, 622, 438);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1176, 12, 933, 898, 620);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1177, 202, 636, 486, 395);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1178, 247, 790, 719, 580);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1179, 214, 520, 485, 457);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1180, 173, 821, 320, 684);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1181, 223, 820, 473, 412);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1182, 274, 611, 664, 307);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1183, 278, 564, 712, 657);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1184, 217, 649, 845, 375);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1185, 176, 703, 736, 582);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1186, 193, 583, 508, 681);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1187, 193, 744, 380, 399);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1188, 2, 932, 909, 659);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1189, 33, 559, 793, 556);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1190, 163, 914, 934, 416);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1191, 232, 673, 711, 619);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1192, 250, 927, 519, 541);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1193, 91, 823, 653, 619);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1194, 223, 589, 767, 345);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1195, 264, 615, 475, 442);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1196, 110, 993, 733, 614);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1197, 189, 958, 620, 369);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1198, 166, 701, 884, 300);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1199, 278, 679, 509, 303);
INSERT INTO ppl.cells( id, parcel_locker_id, height, "length", width ) VALUES ( 1200, 263, 830, 922, 313);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 1, 74, 'lomza', 'Koziarowka', 1569356619, 634, 75746);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 2, 11, 'Ostrzeszow', 'Gorka Narodowa', 1244735654, 642, 17943);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 3, 42, 'Proszowice', 'Obopolna', 1670768664, 200, 54001);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 4, 41, 'Bierutow', 'Franciszka Kowalskiego', 246954374, 18, 51565);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 5, 21, 'Braniewo', 'Nawojowska', 725777588, 559, 50373);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 6, 4, 'lapy', 'Bibicka', 1458175681, 107, 72793);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 7, 34, 'Gniew', 'Ludwika Pasteura', 1164409526, 294, 34999);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 8, 66, 'Czarne', 'Nad zrodlem', 1921760003, 3, 78396);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 9, 97, 'Elk', 'Porzeczkowa', 32657466, 253, 29732);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 10, 72, 'Nowa_Sol', 'Pod Fortem', 2003419961, 576, 92836);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 11, 1, 'Sobotka', 'Wroclawska', 1115391600, 451, 89744);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 12, 16, 'Gubin', 'Stanislawa Konarskiego', 1215774110, 526, 29980);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 13, 97, 'Walcz', 'Cichy Kacik', 948140673, 316, 89548);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 14, 16, 'Dzialdowo', 'Droznicka', 2125427094, 565, 49551);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 15, 94, 'Gniew', 'Gorna', 1471443810, 292, 45358);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 16, 56, 'Klodawa', 'Ludomira Benedyktowicza', 1238206675, 624, 99525);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 17, 95, 'Zielona_Gora', 'Kamedulska', 462341914, 547, 89334);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 18, 92, 'Chelmno', 'Daleka', 1478214759, 243, 35483);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 19, 94, 'swinoujscie', 'Hoza', 742187239, 342, 32304);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 20, 49, 'Wrzesnia', 'Tadeusza Makowskiego', 1080641881, 399, 63420);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 21, 40, 'Olesnica', 'Gleboka', 857217862, 587, 56066);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 22, 92, 'Olkusz', 'Misjonarska', 264618724, 628, 16949);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 23, 35, 'Nowy_Tomysl', 'os.Krowodrza Gorka', 566525399, 607, 13614);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 24, 16, 'Jarocin', 'Kiejstuta zemaitisa', 672416367, 104, 71475);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 25, 30, 'Minsk_Mazowiecki', 'Puszczykow', 1440256876, 317, 50566);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 26, 37, 'Brzesko', 'Astronomow', 955963236, 393, 41909);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 27, 51, 'Wielun', 'Gaik', 937928941, 580, 37166);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 28, 87, 'Golub-Dobrzyn', 'Orna', 407537863, 235, 21289);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 29, 12, 'sroda_Wielkopolska', 'Krancowa', 43509452, 290, 41476);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 30, 54, 'Miedzychod', 'Na Nowinach', 701721867, 501, 72308);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 31, 78, 'Sopot', 'Stanislawa Ciechanowskiego', 575854786, null, 28227);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 32, 59, 'swinoujscie', 'Obozna', 1389544522, 315, 13070);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 33, 66, 'Kudowa-Zdroj', 'Ludwika Wegierskiego', 657855433, 413, 27397);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 34, 5, 'Grudziadz', 'Astronautow', 384112371, null, 30910);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 35, 16, 'lapy', 'Kornela Ujejskiego', 1918029014, 693, 13460);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 36, 77, 'Czarnkow', 'Wladyslawa Podkowinskiego', 163871347, 353, 71563);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 37, 38, 'Siedlce', 'Grzegorza Korzeniaka', 1881560113, 600, 62485);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 38, 63, 'Lubsko', 'Jadwigi Majowny', 305872307, 583, 85010);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 39, 14, 'Rumia', 'Kmieca', 966952066, 332, 65577);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 40, 88, 'sroda_slaska', 'Franciszka Bielaka', 1236623516, 460, 68552);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 41, 70, 'Nasielsk', 'Zakliki z Mydlnik', 1916557732, 438, 34646);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 42, 46, 'Stronie_slaskie', 'Poreba', 1289705008, null, 73251);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 43, 81, 'Zdzieszowice', 'Agrestowa', 359137431, 682, 99929);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 44, 1, 'Ostrowiec_swietokrzyski', 'Czeslawa Niemena', 1927722599, 585, 52811);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 45, 1, 'Szydlowiec', 'Jasnogorska', 2077020608, 65, 18245);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 46, 86, 'Poddebice', 'Skladowa', 978952012, 213, 87212);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 47, 53, 'Gorlice', 'Kaszubska', 493931090, 553, 60445);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 48, 3, 'Polkowice', 'Podchorazych', 1315678205, 263, 54389);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 49, 75, 'Plock', 'Witolda Budryka', 423768607, 287, 85272);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 50, 71, 'Katowice', 'Kopalina', 1504929914, 473, 26464);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 51, 15, 'Kudowa-Zdroj', 'swietokrzyska', 1155482805, 552, 12548);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 52, 28, 'Przemysl', 'Stefana Jaracza', 308393867, 314, 26594);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 53, 49, 'swinoujscie', 'Jadwigi z lobzowa', 1550240985, null, 89804);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 54, 8, 'Lebork', 'al.Konarowa', 1873010671, 173, 24320);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 55, 55, 'Sulecin', 'Redzina', 1318700120, null, 94947);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 56, 62, 'Strzelce_Krajenskie', 'Karola Szymanowskiego', 309604552, 104, 62176);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 57, 58, 'Jastrzebie-Zdroj', 'Szaserow', 1019554996, 190, 10707);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 58, 96, 'Pyrzyce', 'al.Jerzego Waszyngtona', 1773168907, 685, 61662);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 59, 21, 'Cieszyn', 'Jozefa Wybickiego', 283930466, 54, 10529);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 60, 28, 'Bialogard', 'Syreny', 1745068610, 536, 79847);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 61, 63, 'Trzebinia', 'Olszanicka', 1923070370, 651, 36608);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 62, 20, 'Trzebinia', 'Akademicka', 1915320901, 655, 67895);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 63, 19, 'Bierun_Ledziny', 'Emaus', 1626269238, 173, 88947);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 64, 1, 'Dlugoleka', 'Zaklucze', 258629612, 378, 63504);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 65, 2, 'Choszczno', 'Orna', 2099291308, 560, 35358);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 66, 69, 'Bielsko-Biala', 'os.Srebrne Uroczysko', 1896678284, 69, 11340);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 67, 17, 'Bierun_Ledziny', 'Zakret', 526300036, 565, 40010);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 68, 49, 'Wielun', 'Mieczyslawa Karlowicza', 1308036464, 121, 79299);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 69, 18, 'Krasnik', 'Mrowczana', 394468399, 336, 97417);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 70, 49, 'Belzyce', 'Olkuska', 1308056751, 513, 16199);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 71, 55, 'swidnik', 'Daniela Chodowieckiego', 96437419, 304, 17435);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 72, 13, 'Kolobrzeg', 'Baltycka', 777400355, 213, 85069);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 73, 98, 'lomianki', 'Koralowa', 941017132, 447, 98924);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 74, 14, 'Minsk_Mazowiecki', 'Tkacka', 1131133799, 204, 79583);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 75, 25, 'Raciborz', 'Rzepichy', 2075273580, 596, 27139);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 76, 21, 'Pleszew', 'Filtrowa', 2135149003, 191, 12494);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 77, 40, 'Klodawa', 'Biala', 1327402723, 198, 15546);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 78, 85, 'Jaroslaw', 'Borowczana', 1943876046, 408, 20062);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 79, 22, 'Goldap', 'Jozefa Rostafinskiego', 1771265351, 267, 82893);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 80, 41, 'Imielin', 'Emilii Plater', 41810506, 347, 24885);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 81, 44, 'Zlotow', 'Podluzna', 1521197201, 485, 82644);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 82, 95, 'Znin', 'Zakamycze', 889271392, null, 78654);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 83, 24, 'Rawa_Mazowiecka', 'Biale Wzgorze', 781407860, 139, 84839);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 84, 53, 'Bolkow', 'Mieczyslawa Maleckiego', 1611770508, 696, 42497);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 85, 89, 'Ostrow_Wielkopolski', 'Jana Buszka', 129354713, 242, 20783);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 86, 39, 'Brzeg_Dolny', 'Zaczarowane Kolo', 773105821, 395, 34291);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 87, 4, 'Chelmza', 'Bibicka', 362225385, 142, 23160);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 88, 28, 'Brzeg_Dolny', 'Porzecze', 2084191664, null, 92871);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 89, 60, 'Pruszkow', 'Berberysowa', 2144475662, 603, 58119);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 90, 12, 'Zdzieszowice', 'Amazonek', 1910274706, 48, 48379);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 91, 66, 'Poznan', 'Adama Staszczyka', 1565832406, 185, 50018);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 92, 23, 'Zabrze', 'Skladowa', 2083343531, 199, 55856);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 93, 12, 'Tarnobrzeg', 'Brzegowa', 772322228, 673, 62893);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 94, 100, 'Goldap', 'Karola Popiela', 759872479, 611, 97280);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 95, 66, 'Krasnystaw', 'Wiedenska', 624619999, 573, 87777);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 96, 59, 'Luban', 'Turystyczna', 407594854, 423, 91698);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 97, 99, 'Pyrzyce', 'Adama Chmiela', 879430696, 654, 59833);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 98, 97, 'Grodzisk_Mazowiecki', 'Gnieznienska', 1473333658, 505, 97297);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 99, 21, 'Naklo_nad_Notecia', 'Kaczorowka', 1372994624, 481, 40449);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 100, 27, 'Pruszcz_Gdanski', 'Zygmunta Starego', 1347346315, 539, 35873);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 101, 38, 'Wolomin', 'Skotnica', 2133546684, null, 94080);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 102, 37, 'Zelow', 'Wincentego Danka', 176880293, 71, 54051);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 103, 47, 'Ilawa', 'Maczna', 1082326755, null, 28363);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 104, 88, 'Olecko', 'Torunska', 808557262, 63, 96141);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 105, 34, 'Reda', 'Redzina', 1494630853, 228, 75024);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 106, 30, 'Zbaszyn', 'Mlaskotow', 1065637335, 80, 27010);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 107, 45, 'Proszowice', 'Drozyna', 1801382249, 113, 53115);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 108, 6, 'Sierpc', 'Nad Zalewem', 312667301, 614, 95774);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 109, 51, 'Rawicz', 'Wernyhory', 544209968, 210, 80282);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 110, 19, 'Skoczow', 'Wojciecha Halczyna', 982306854, 247, 60399);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 111, 100, 'Zakopane', 'Stanislawa Rokosza', 1804204179, 569, 30985);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 112, 64, 'Orzesze', 'Marii Jaremy', 805730596, 541, 71821);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 113, 64, 'Plonsk', 'Aleksandra Prystora', 978682015, 383, 67011);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 114, 28, 'Ropczyce', 'Wiosenna', 1092195188, 693, 43672);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 115, 91, 'Siechnice', 'Zaborska', 417875492, 47, 68251);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 116, 35, 'Debica', 'Eugeniusza Romera', 1326784334, null, 18840);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 117, 51, 'Kowary', 'Juliana Tokarskiego', 635644487, 11, 63696);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 118, 27, 'Tarnow', 'Zygmunta Starego', 249744345, 367, 78346);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 119, 50, 'Pszczyna', 'Gabrieli Zapolskiej', 1538630125, 568, 71060);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 120, 12, 'Pinczow', 'Daniela Chodowieckiego', 374925931, 669, 46620);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 121, 43, 'Zagan', 'Bibicka', 394367355, 30, 50632);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 122, 14, 'Rawicz', 'Malownicza', 553942723, null, 13082);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 123, 31, 'Nowy_Dwor_Gdanski', 'Stelmachow', 492564813, 249, 75858);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 124, 55, 'Sanok', 'Przyjemna', 1272778019, 30, 65059);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 125, 72, 'Sosnowiec', 'Jana Stanislawskiego', 1339666081, 39, 81409);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 126, 50, 'Pabianice', 'Tadeusza Ochlewskiego', 25946360, 48, 15603);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 127, 97, 'Kety', 'Kopalina', 589125580, null, 43794);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 128, 2, 'Jelenia_Gora', 'Niezapominajek', 1116398572, 685, 40599);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 129, 21, 'Debica', 'Przepiorcza', 1896958026, null, 80910);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 130, 36, 'Olecko', 'Mieczyslawa Karlowicza', 830104666, 412, 48305);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 131, 18, 'Konstancin-Jeziorna', 'inneKopiec Kosciuszki', 2118330139, 601, 93927);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 132, 25, 'Miedzyrzecz', 'Zygmunta Myslakowskiego', 1254948388, null, 56396);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 133, 55, 'Plonsk', 'Poniedzialkowy Dol', 1745921528, 457, 37518);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 134, 81, 'Lubawka', 'Jozefa Friedleina', 661051115, 219, 24210);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 135, 56, 'Gniezno', 'Dziewanny', 581080963, 100, 75638);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 136, 11, 'Grudziadz', 'Jaskolcza', 909193643, 324, 62749);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 137, 59, 'Bierutow', 'Mlodej Polski', 380800135, 44, 38600);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 138, 52, 'Rawicz', 'Nawigacyjna', 352757941, 280, 21280);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 139, 79, 'Strzelce_Krajenskie', 'Piotra Kluzeka', 493373591, 46, 90154);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 140, 53, 'Skawina', 'Jerzego Samuela Bandtkiego', 1541583933, 274, 75223);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 141, 70, 'Limanowa', 'Wladyslawa lokietka', 1189053317, 405, 98620);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 142, 37, 'Tuszyn', 'Waleczna', 1174880699, 317, 46097);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 143, 21, 'Gniew', 'dr. Twardego', 1396410408, 345, 84819);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 144, 45, 'Bydgoszcz', 'Ksiecia Jozefa', 234175919, 328, 55373);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 145, 26, 'Nowy_Sacz', 'Wladyslawa Syrokomli', 229990489, 695, 18723);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 146, 70, 'Andrychow', 'Pod Szancami', 1858146459, 475, 22353);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 147, 78, 'Tomaszow_Mazowiecki', 'Warmijska', 501900309, 419, 11387);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 148, 18, 'Belzyce', 'Nad Zalewem', 362427158, 233, 12995);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 149, 23, 'swiecie', 'Na Wyrebe', 687610555, 149, 45061);
INSERT INTO ppl.user_addresses( id, user_id, city, street, house_number, flat_number, postal_code ) VALUES ( 150, 70, 'sroda_slaska', 'Eugeniusza Romera', 695015670, 617, 55709);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 1, 731, 731, 731, 731, 74, 110, 'Place', 74, 110, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 2, 410, 901, 71, 919, 18, 56, 'Courier', 99, 38, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 3, 208, 497, 67, 919, 9, 87, 'Parcel_locker', 60, 115, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 4, 333, 986, 768, 680, 62, 32, 'Parcel_locker', 2, 123, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 5, 968, 857, 227, 78, 49, 117, 'Place', 20, 116, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 6, 6, 987, 660, 25, 95, 115, 'Parcel_locker', 13, 129, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 7, 964, 228, 807, 699, 47, 18, 'Courier', 81, 89, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 8, 940, 75, 30, 805, 83, 31, 'Courier', 46, 150, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 9, 947, 743, 811, 151, 45, 51, 'Courier', 56, 140, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 10, 937, 950, 945, 925, 43, 96, 'Parcel_locker', 22, 22, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 11, 397, 31, 153, 764, 70, 102, 'Place', 72, 59, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 12, 348, 692, 910, 3, 76, 8, 'Place', 46, 53, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 13, 294, 852, 999, 736, 28, 82, 'Courier', 2, 89, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 14, 506, 57, 540, 956, 35, 106, 'Courier', 99, 80, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 15, 116, 408, 978, 824, 76, 135, 'Courier', 63, 88, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 16, 771, 352, 158, 189, 84, 19, 'Parcel_locker', 56, 19, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 17, 660, 994, 549, 326, 22, 3, 'Courier', 43, 74, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 18, 157, 562, 94, 752, 47, 120, 'Courier', 13, 3, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 19, 378, 476, 443, 280, 93, 140, 'Courier', 91, 136, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 20, 140, 49, 413, 230, 74, 120, 'Place', 67, 147, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 21, 695, 582, 286, 808, 89, 78, 'Parcel_locker', 26, 57, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 22, 805, 851, 169, 759, 32, 78, 'Courier', 13, 109, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 23, 5, 229, 487, 781, 23, 85, 'Courier', 88, 15, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 24, 523, 153, 943, 893, 33, 143, 'Place', 70, 74, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 25, 744, 964, 891, 524, 89, 67, 'Place', 33, 72, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 26, 142, 233, 536, 51, 3, 5, 'Courier', 2, 102, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 27, 482, 617, 572, 347, 44, 149, 'Parcel_locker', 89, 56, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 28, 545, 609, 254, 480, 32, 110, 'Place', 91, 116, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 29, 577, 248, 691, 907, 40, 103, 'Courier', 11, 101, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 30, 205, 839, 961, 570, 66, 11, 'Courier', 25, 117, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 31, 623, 689, 334, 558, 100, 87, 'Parcel_locker', 42, 33, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 32, 185, 798, 260, 572, 67, 91, 'Courier', 73, 112, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 33, 11, 124, 419, 898, 89, 33, 'Parcel_locker', 55, 16, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 34, 161, 108, 125, 215, 20, 125, 'Courier', 57, 54, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 35, 178, 33, 748, 323, 29, 104, 'Courier', 88, 62, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 36, 540, 933, 469, 148, 67, 36, 'Parcel_locker', 10, 86, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 37, 974, 267, 169, 681, 25, 52, 'Place', 16, 18, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 38, 245, 554, 451, 936, 7, 35, 'Place', 89, 75, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 39, 395, 227, 283, 562, 60, 76, 'Courier', 69, 8, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 40, 218, 143, 501, 292, 49, 118, 'Courier', 20, 15, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 41, 432, 51, 511, 813, 52, 60, 'Courier', 63, 50, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 42, 233, 131, 498, 335, 50, 32, 'Place', 79, 82, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 43, 890, 58, 335, 722, 8, 19, 'Courier', 4, 53, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 44, 38, 460, 320, 616, 56, 22, 'Courier', 97, 16, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 45, 592, 468, 843, 717, 5, 40, 'Courier', 82, 12, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 46, 655, 253, 54, 57, 34, 109, 'Parcel_locker', 96, 124, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 47, 120, 789, 900, 450, 69, 47, 'Courier', 6, 127, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 48, 652, 772, 732, 533, 84, 72, 'Courier', 20, 98, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 49, 984, 345, 558, 623, 46, 101, 'Parcel_locker', 24, 24, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 50, 207, 725, 219, 689, 48, 60, 'Courier', 56, 37, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 51, 375, 884, 48, 865, 36, 67, 'Courier', 27, 86, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 52, 463, 423, 103, 504, 73, 21, 'Courier', 32, 27, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 53, 334, 169, 557, 498, 31, 66, 'Courier', 17, 19, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 54, 443, 156, 585, 730, 48, 64, 'Parcel_locker', 53, 131, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 55, 504, 174, 284, 834, 13, 29, 'Parcel_locker', 7, 106, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 56, 999, 563, 709, 435, 12, 36, 'Parcel_locker', 100, 93, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 57, 630, 97, 942, 163, 35, 4, 'Parcel_locker', 68, 19, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 58, 910, 161, 77, 658, 60, 55, 'Place', 82, 34, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 59, 508, 634, 259, 381, 70, 50, 'Courier', 6, 27, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 60, 491, 528, 849, 455, 63, 55, 'Courier', 90, 147, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 61, 429, 29, 495, 829, 21, 41, 'Courier', 14, 118, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 62, 308, 557, 140, 59, 73, 12, 'Parcel_locker', 38, 39, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 63, 717, 597, 637, 837, 4, 98, 'Parcel_locker', 43, 133, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 64, 962, 488, 646, 436, 33, 50, 'Courier', 32, 97, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 65, 209, 905, 673, 514, 20, 46, 'Courier', 9, 57, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 66, 173, 41, 752, 304, 17, 46, 'Parcel_locker', 2, 96, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 67, 549, 461, 157, 637, 24, 27, 'Parcel_locker', 29, 46, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 68, 555, 395, 448, 716, 100, 93, 'Courier', 38, 76, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 69, 588, 800, 396, 375, 4, 134, 'Courier', 19, 135, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 70, 789, 329, 149, 249, 35, 106, 'Courier', 99, 30, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 71, 699, 661, 7, 737, 69, 12, 'Courier', 30, 125, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 72, 205, 733, 890, 677, 97, 88, 'Courier', 35, 121, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 73, 255, 705, 888, 805, 59, 132, 'Parcel_locker', 30, 29, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 74, 778, 531, 280, 24, 90, 86, 'Parcel_locker', 22, 99, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 75, 225, 1, 742, 449, 84, 22, 'Parcel_locker', 53, 64, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 76, 983, 950, 961, 17, 77, 90, 'Courier', 94, 50, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 77, 804, 360, 175, 247, 62, 68, 'Place', 79, 127, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 78, 836, 630, 699, 43, 81, 13, 'Parcel_locker', 53, 114, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 79, 163, 178, 840, 148, 66, 87, 'Place', 73, 13, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 80, 637, 492, 874, 783, 31, 133, 'Place', 73, 30, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 81, 9, 910, 610, 108, 28, 134, 'Courier', 66, 18, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 82, 631, 282, 65, 980, 78, 24, 'Parcel_locker', 39, 89, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 83, 208, 740, 896, 676, 71, 91, 'Place', 81, 26, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 84, 880, 270, 140, 491, 47, 77, 'Courier', 43, 63, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 85, 707, 647, 1, 767, 100, 26, 'Courier', 84, 17, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 86, 723, 813, 450, 633, 76, 110, 'Courier', 79, 19, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 87, 509, 532, 191, 487, 48, 135, 'Courier', 6, 137, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 88, 987, 37, 20, 937, 12, 35, 'Place', 100, 143, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 89, 153, 617, 463, 689, 10, 146, 'Courier', 22, 89, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 90, 711, 174, 353, 247, 76, 4, 'Place', 48, 59, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 91, 824, 108, 14, 539, 86, 69, 'Courier', 26, 10, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 92, 124, 584, 431, 663, 82, 57, 'Parcel_locker', 26, 60, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 93, 617, 389, 132, 845, 57, 35, 'Place', 90, 1, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 94, 482, 866, 738, 98, 31, 86, 'Courier', 4, 92, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 95, 100, 526, 718, 673, 50, 92, 'Courier', 38, 51, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 96, 617, 899, 472, 335, 93, 139, 'Courier', 93, 40, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 97, 28, 884, 265, 172, 84, 30, 'Courier', 48, 104, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 98, 591, 308, 402, 875, 2, 147, 'Place', 7, 12, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 99, 73, 374, 940, 772, 19, 106, 'Parcel_locker', 67, 24, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 100, 74, 414, 967, 734, 57, 127, 'Place', 30, 131, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 101, 680, 739, 53, 621, 3, 81, 'Parcel_locker', 52, 103, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 102, 280, 873, 675, 687, 63, 102, 'Place', 57, 133, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 103, 604, 904, 804, 304, 19, 22, 'Courier', 23, 136, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 104, 850, 269, 796, 430, 82, 55, 'Place', 27, 112, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 105, 354, 327, 669, 380, 89, 109, 'Parcel_locker', 6, 66, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 106, 599, 906, 803, 291, 39, 123, 'Place', 95, 71, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 107, 292, 652, 199, 932, 16, 131, 'Place', 45, 132, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 108, 876, 69, 338, 684, 79, 73, 'Courier', 9, 78, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 109, 744, 217, 726, 272, 95, 93, 'Place', 28, 58, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 110, 423, 321, 355, 526, 48, 114, 'Courier', 19, 114, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 111, 376, 983, 447, 769, 58, 22, 'Parcel_locker', 2, 25, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 112, 271, 960, 63, 583, 9, 38, 'Courier', 93, 81, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 113, 730, 552, 278, 908, 1, 72, 'Place', 55, 58, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 114, 887, 21, 643, 752, 67, 94, 'Place', 72, 10, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 115, 44, 591, 742, 496, 58, 124, 'Courier', 33, 36, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 116, 458, 977, 137, 938, 44, 55, 'Parcel_locker', 52, 81, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 117, 862, 562, 995, 163, 1, 20, 'Courier', 88, 76, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 118, 902, 259, 473, 545, 42, 8, 'Courier', 78, 85, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 119, 62, 101, 755, 24, 78, 122, 'Parcel_locker', 74, 10, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 120, 764, 532, 942, 996, 1, 14, 'Courier', 93, 136, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 121, 428, 160, 916, 696, 30, 135, 'Courier', 70, 25, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 122, 999, 223, 482, 775, 93, 13, 'Courier', 77, 106, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 123, 62, 560, 727, 564, 65, 134, 'Courier', 40, 147, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 124, 586, 567, 574, 605, 12, 29, 'Courier', 4, 103, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 125, 567, 398, 454, 737, 88, 114, 'Place', 100, 6, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 126, 662, 612, 962, 712, 33, 106, 'Parcel_locker', 95, 24, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 127, 907, 806, 173, 8, 60, 19, 'Parcel_locker', 7, 34, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 128, 246, 426, 700, 67, 45, 57, 'Parcel_locker', 53, 133, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 129, 248, 344, 979, 153, 29, 147, 'Courier', 59, 54, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 130, 707, 668, 347, 746, 52, 60, 'Courier', 63, 100, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 131, 338, 392, 40, 284, 2, 133, 'Courier', 15, 129, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 132, 607, 676, 653, 538, 83, 59, 'Courier', 27, 62, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 133, 315, 823, 320, 808, 34, 37, 'Courier', 43, 18, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 134, 24, 174, 458, 875, 12, 20, 'Place', 11, 66, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 135, 451, 992, 812, 910, 78, 92, 'Place', 94, 148, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 136, 369, 206, 261, 532, 70, 77, 'Parcel_locker', 89, 43, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 137, 464, 323, 37, 604, 98, 28, 'Courier', 76, 54, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 138, 177, 216, 203, 138, 33, 71, 'Parcel_locker', 18, 19, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 139, 676, 15, 569, 337, 7, 92, 'Place', 53, 53, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 140, 716, 709, 711, 722, 38, 74, 'Courier', 26, 33, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 141, 743, 312, 123, 174, 9, 7, 'Courier', 13, 70, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 142, 929, 75, 693, 783, 30, 52, 'Parcel_locker', 26, 36, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 143, 590, 409, 469, 771, 84, 55, 'Parcel_locker', 31, 70, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 144, 644, 249, 714, 39, 7, 15, 'Courier', 3, 103, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 145, 110, 121, 117, 100, 99, 66, 'Place', 54, 109, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 146, 775, 503, 593, 47, 49, 60, 'Place', 58, 41, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 147, 306, 525, 452, 88, 78, 80, 'Place', 2, 116, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 148, 881, 16, 304, 745, 43, 36, 'Courier', 61, 101, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 149, 630, 561, 251, 700, 20, 145, 'Courier', 42, 24, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 150, 929, 745, 139, 113, 47, 59, 'Parcel_locker', 54, 35, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 151, 197, 249, 232, 144, 3, 150, 'Courier', 7, 11, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 152, 755, 492, 913, 17, 72, 57, 'Courier', 6, 76, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 153, 158, 436, 343, 879, 7, 93, 'Place', 51, 48, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 154, 42, 122, 429, 962, 30, 20, 'Courier', 47, 128, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 155, 379, 516, 804, 241, 12, 136, 'Parcel_locker', 32, 59, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 156, 787, 220, 742, 353, 58, 70, 'Place', 69, 9, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 157, 713, 141, 665, 285, 81, 124, 'Courier', 80, 69, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 158, 110, 673, 485, 548, 64, 36, 'Courier', 3, 124, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 159, 762, 751, 755, 773, 17, 3, 'Courier', 32, 104, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 160, 30, 80, 63, 981, 26, 46, 'Parcel_locker', 21, 29, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 161, 317, 625, 856, 8, 81, 107, 'Parcel_locker', 91, 91, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 162, 667, 343, 117, 992, 31, 85, 'Place', 4, 143, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 163, 426, 751, 643, 102, 77, 63, 'Parcel_locker', 12, 135, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 164, 401, 456, 771, 345, 96, 3, 'Place', 90, 82, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 165, 744, 107, 319, 381, 84, 55, 'Parcel_locker', 30, 69, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 166, 365, 490, 781, 241, 80, 95, 'Courier', 97, 103, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 167, 764, 3, 590, 525, 37, 113, 'Courier', 98, 127, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 168, 323, 5, 444, 640, 75, 63, 'Courier', 8, 28, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 169, 513, 26, 188, 1000, 12, 10, 'Courier', 18, 80, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 170, 479, 0, 493, 957, 77, 120, 'Parcel_locker', 73, 107, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 171, 131, 465, 21, 797, 27, 55, 'Parcel_locker', 18, 123, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 172, 32, 749, 177, 314, 44, 140, 'Place', 94, 66, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 173, 444, 930, 102, 959, 15, 26, 'Parcel_locker', 13, 118, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 174, 692, 157, 335, 227, 94, 42, 'Place', 60, 122, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 175, 719, 396, 170, 42, 93, 146, 'Parcel_locker', 88, 129, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 176, 778, 97, 658, 459, 74, 81, 'Courier', 94, 51, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 177, 288, 153, 532, 423, 54, 150, 'Parcel_locker', 8, 138, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 178, 781, 495, 257, 67, 13, 72, 'Courier', 78, 100, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 179, 966, 890, 582, 42, 43, 134, 'Place', 97, 22, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 180, 997, 13, 341, 980, 53, 89, 'Parcel_locker', 47, 16, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 181, 239, 385, 337, 93, 45, 110, 'Courier', 17, 10, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 182, 445, 302, 683, 589, 30, 106, 'Place', 89, 13, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 183, 130, 418, 322, 842, 51, 146, 'Courier', 5, 135, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 184, 234, 951, 46, 518, 52, 56, 'Place', 67, 57, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 185, 656, 499, 551, 813, 59, 54, 'Parcel_locker', 82, 84, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 186, 572, 39, 883, 106, 46, 97, 'Courier', 28, 32, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 187, 556, 800, 52, 312, 97, 54, 'Parcel_locker', 59, 69, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 188, 250, 375, 0, 125, 15, 148, 'Parcel_locker', 31, 4, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 189, 920, 267, 151, 574, 87, 44, 'Place', 44, 95, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 190, 724, 985, 231, 463, 73, 147, 'Courier', 47, 58, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 191, 777, 724, 408, 830, 91, 29, 'Courier', 63, 30, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 192, 242, 647, 179, 837, 5, 31, 'Place', 89, 75, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 193, 176, 951, 693, 400, 56, 62, 'Courier', 70, 12, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 194, 445, 568, 194, 321, 14, 38, 'Courier', 3, 149, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 195, 830, 154, 379, 505, 97, 103, 'Place', 26, 53, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 196, 602, 813, 743, 391, 80, 127, 'Parcel_locker', 76, 11, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 197, 638, 74, 262, 202, 34, 96, 'Courier', 4, 91, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 198, 303, 427, 386, 180, 33, 4, 'Parcel_locker', 64, 60, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 199, 65, 677, 473, 453, 29, 95, 'Courier', 95, 76, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 200, 938, 359, 552, 517, 61, 55, 'Place', 85, 139, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 201, 266, 86, 146, 447, 94, 150, 'Courier', 88, 29, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 202, 229, 990, 70, 468, 70, 136, 'Courier', 49, 113, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 203, 304, 153, 537, 455, 49, 13, 'Place', 90, 105, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 204, 372, 319, 3, 425, 56, 24, 'Parcel_locker', 96, 115, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 205, 857, 36, 976, 678, 21, 76, 'Place', 91, 121, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 206, 807, 492, 264, 122, 92, 15, 'Courier', 73, 101, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 207, 389, 808, 2, 969, 96, 57, 'Courier', 54, 10, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 208, 265, 198, 887, 333, 74, 69, 'Parcel_locker', 1, 15, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 209, 32, 830, 898, 235, 73, 105, 'Courier', 75, 14, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 210, 670, 656, 994, 684, 100, 26, 'Place', 81, 63, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 211, 74, 266, 202, 883, 19, 75, 'Courier', 89, 117, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 212, 609, 74, 585, 145, 17, 109, 'Place', 61, 13, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 213, 179, 102, 461, 256, 48, 126, 'Courier', 12, 100, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 214, 30, 950, 310, 109, 13, 45, 'Courier', 97, 37, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 215, 708, 870, 150, 546, 96, 22, 'Courier', 77, 5, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 216, 278, 884, 682, 671, 21, 26, 'Place', 24, 87, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 217, 116, 257, 543, 974, 79, 39, 'Courier', 31, 123, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 218, 691, 236, 388, 146, 42, 77, 'Courier', 33, 45, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 219, 349, 55, 820, 643, 56, 69, 'Parcel_locker', 67, 105, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 220, 228, 336, 967, 120, 83, 29, 'Parcel_locker', 47, 3, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 221, 168, 788, 581, 547, 24, 127, 'Place', 63, 14, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 222, 595, 816, 409, 374, 52, 91, 'Place', 42, 9, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 223, 810, 449, 569, 171, 69, 57, 'Parcel_locker', 100, 16, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 224, 515, 111, 913, 918, 100, 22, 'Parcel_locker', 84, 19, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 225, 349, 510, 790, 188, 64, 69, 'Place', 82, 81, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 226, 53, 404, 954, 702, 58, 149, 'Courier', 17, 55, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 227, 606, 862, 777, 351, 38, 77, 'Parcel_locker', 24, 130, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 228, 682, 39, 920, 324, 99, 95, 'Courier', 34, 19, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 229, 584, 997, 859, 170, 65, 30, 'Courier', 10, 38, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 230, 370, 285, 313, 454, 17, 18, 'Place', 21, 134, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 231, 946, 299, 182, 593, 10, 93, 'Courier', 58, 111, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 232, 686, 675, 12, 698, 82, 69, 'Courier', 17, 43, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 233, 225, 114, 817, 336, 60, 45, 'Courier', 90, 50, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 234, 445, 980, 468, 909, 1, 34, 'Courier', 79, 108, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 235, 708, 664, 678, 751, 76, 18, 'Courier', 41, 93, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 236, 30, 305, 213, 754, 91, 119, 'Courier', 2, 108, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 237, 659, 198, 352, 120, 68, 108, 'Courier', 65, 45, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 238, 316, 72, 487, 560, 7, 66, 'Place', 70, 87, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 239, 816, 870, 519, 762, 41, 27, 'Place', 64, 8, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 240, 156, 737, 543, 574, 63, 53, 'Courier', 91, 149, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 241, 453, 179, 937, 728, 46, 28, 'Place', 72, 72, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 242, 320, 458, 745, 182, 60, 127, 'Courier', 35, 89, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 243, 550, 681, 970, 419, 4, 39, 'Parcel_locker', 82, 11, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 244, 522, 350, 408, 694, 46, 14, 'Parcel_locker', 82, 141, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 245, 315, 589, 498, 42, 74, 35, 'Courier', 24, 61, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 246, 696, 164, 675, 228, 80, 64, 'Courier', 18, 146, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 247, 95, 691, 492, 499, 62, 89, 'Courier', 64, 96, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 248, 959, 810, 193, 108, 76, 16, 'Place', 41, 143, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 249, 130, 246, 207, 13, 80, 94, 'Place', 97, 3, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 250, 24, 68, 720, 979, 56, 7, 'Courier', 6, 85, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 251, 85, 535, 385, 635, 7, 2, 'Place', 12, 70, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 252, 52, 511, 25, 594, 42, 114, 'Place', 8, 95, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 253, 470, 125, 240, 815, 38, 42, 'Courier', 48, 127, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 254, 820, 291, 800, 349, 54, 58, 'Courier', 69, 11, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 255, 969, 574, 706, 364, 34, 78, 'Parcel_locker', 17, 66, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 256, 350, 312, 992, 388, 47, 60, 'Place', 54, 34, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 257, 273, 781, 945, 764, 79, 133, 'Place', 70, 50, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 258, 11, 784, 860, 238, 73, 51, 'Courier', 12, 87, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 259, 794, 38, 957, 550, 43, 58, 'Parcel_locker', 47, 22, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 260, 100, 355, 604, 846, 76, 125, 'Courier', 69, 100, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 261, 819, 545, 970, 93, 94, 148, 'Courier', 88, 80, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 262, 748, 639, 9, 857, 19, 132, 'Courier', 49, 88, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 263, 380, 819, 673, 941, 52, 88, 'Parcel_locker', 45, 64, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 264, 108, 797, 900, 419, 88, 20, 'Courier', 63, 82, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 265, 766, 572, 303, 960, 31, 122, 'Courier', 80, 45, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 266, 209, 943, 365, 475, 52, 119, 'Courier', 25, 23, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 267, 945, 924, 598, 966, 16, 47, 'Place', 1, 44, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 268, 28, 110, 416, 945, 89, 53, 'Place', 44, 142, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 269, 747, 765, 92, 729, 73, 41, 'Courier', 19, 2, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 270, 636, 600, 945, 673, 68, 18, 'Courier', 23, 12, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 271, 939, 858, 551, 19, 59, 64, 'Courier', 75, 121, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 272, 94, 188, 157, 1000, 73, 55, 'Courier', 8, 130, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 273, 960, 527, 338, 393, 32, 27, 'Courier', 46, 26, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 274, 819, 375, 856, 262, 57, 36, 'Place', 89, 150, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 275, 215, 83, 460, 347, 13, 25, 'Place', 9, 12, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 276, 834, 867, 856, 801, 57, 102, 'Parcel_locker', 47, 14, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 277, 256, 272, 266, 240, 90, 35, 'Courier', 56, 16, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 278, 641, 580, 600, 702, 42, 109, 'Parcel_locker', 11, 150, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 279, 716, 39, 265, 394, 73, 108, 'Place', 74, 111, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 280, 802, 642, 29, 961, 98, 140, 'Parcel_locker', 3, 57, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 281, 461, 641, 248, 282, 99, 84, 'Courier', 42, 34, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 282, 120, 221, 521, 18, 95, 26, 'Courier', 72, 147, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 283, 511, 128, 589, 893, 41, 83, 'Place', 26, 131, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 284, 743, 298, 780, 188, 28, 130, 'Place', 68, 123, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 285, 57, 406, 623, 707, 84, 98, 'Parcel_locker', 2, 11, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 286, 560, 166, 297, 954, 14, 40, 'Parcel_locker', 100, 93, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 287, 368, 488, 114, 248, 51, 17, 'Courier', 90, 55, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 288, 882, 865, 870, 900, 90, 72, 'Courier', 31, 117, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 289, 880, 118, 705, 642, 10, 17, 'Courier', 9, 13, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 290, 60, 829, 906, 292, 52, 119, 'Courier', 25, 74, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 291, 72, 345, 587, 798, 14, 130, 'Place', 41, 75, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 292, 229, 855, 313, 604, 99, 132, 'Place', 11, 21, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 293, 223, 646, 505, 799, 2, 36, 'Courier', 80, 109, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 294, 645, 178, 667, 113, 46, 101, 'Courier', 24, 25, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 295, 293, 231, 251, 355, 4, 26, 'Courier', 90, 28, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 296, 886, 986, 619, 786, 65, 104, 'Parcel_locker', 60, 138, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 297, 544, 916, 459, 173, 39, 49, 'Courier', 46, 23, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 298, 702, 402, 836, 1, 75, 129, 'Courier', 65, 142, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 299, 183, 358, 299, 8, 51, 49, 'Place', 70, 14, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 300, 347, 661, 890, 34, 22, 107, 'Courier', 72, 83, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 301, 40, 282, 535, 797, 13, 27, 'Courier', 8, 9, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 302, 249, 390, 676, 109, 80, 134, 'Courier', 71, 51, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 303, 797, 36, 623, 557, 44, 27, 'Courier', 71, 19, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 304, 708, 348, 135, 68, 14, 145, 'Place', 30, 4, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 305, 466, 208, 627, 725, 79, 10, 'Parcel_locker', 51, 63, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 306, 803, 310, 141, 296, 35, 99, 'Parcel_locker', 3, 39, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 307, 82, 61, 735, 103, 27, 53, 'Place', 19, 75, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 308, 480, 587, 551, 372, 55, 122, 'Courier', 28, 79, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 309, 961, 109, 60, 813, 53, 100, 'Place', 40, 102, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 310, 238, 959, 52, 517, 34, 131, 'Place', 81, 94, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 311, 453, 650, 251, 256, 88, 47, 'Courier', 45, 145, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 312, 481, 797, 25, 165, 70, 52, 'Courier', 5, 74, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 313, 66, 524, 371, 607, 81, 36, 'Parcel_locker', 39, 136, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 314, 109, 208, 175, 9, 66, 20, 'Place', 18, 3, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 315, 893, 647, 729, 140, 37, 139, 'Place', 80, 92, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 316, 864, 220, 768, 509, 68, 78, 'Courier', 85, 85, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 317, 799, 16, 277, 582, 78, 115, 'Courier', 79, 119, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 318, 350, 853, 685, 847, 12, 139, 'Place', 31, 105, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 319, 130, 378, 962, 882, 97, 3, 'Place', 92, 135, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 320, 892, 321, 845, 463, 26, 20, 'Place', 39, 15, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 321, 432, 572, 859, 292, 24, 83, 'Courier', 94, 25, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 322, 130, 393, 306, 866, 4, 136, 'Place', 16, 31, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 323, 670, 789, 82, 550, 77, 67, 'Courier', 10, 130, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 324, 518, 703, 308, 332, 86, 26, 'Courier', 55, 118, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 325, 554, 597, 583, 511, 100, 48, 'Courier', 67, 85, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 326, 917, 792, 833, 42, 60, 1, 'Place', 20, 109, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 327, 380, 197, 925, 564, 67, 108, 'Courier', 61, 138, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 328, 172, 147, 822, 198, 38, 59, 'Courier', 36, 102, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 329, 133, 985, 701, 281, 60, 144, 'Courier', 24, 67, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 330, 478, 47, 858, 909, 84, 56, 'Parcel_locker', 31, 19, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 331, 875, 296, 156, 454, 54, 99, 'Courier', 41, 106, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 332, 412, 670, 917, 155, 68, 147, 'Parcel_locker', 38, 42, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 333, 529, 171, 957, 888, 12, 53, 'Courier', 88, 69, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 334, 633, 519, 224, 747, 40, 51, 'Courier', 45, 20, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 335, 161, 847, 618, 475, 8, 115, 'Place', 40, 126, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 336, 246, 630, 502, 863, 80, 127, 'Parcel_locker', 75, 111, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 337, 852, 513, 293, 191, 17, 102, 'Courier', 65, 122, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 338, 49, 276, 201, 822, 23, 97, 'Courier', 80, 98, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 339, 890, 810, 170, 969, 45, 146, 'Courier', 93, 64, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 340, 28, 739, 835, 316, 1, 2, 'Parcel_locker', 1, 150, 'Parcel_locker', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 341, 612, 827, 422, 397, 36, 103, 'Place', 2, 87, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 342, 290, 405, 366, 176, 5, 7, 'Place', 5, 7, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 343, 82, 585, 84, 579, 75, 69, 'Courier', 3, 68, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 344, 771, 539, 950, 4, 89, 47, 'Courier', 47, 50, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 345, 359, 404, 723, 314, 13, 93, 'Courier', 65, 123, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 346, 603, 112, 942, 94, 39, 45, 'Place', 48, 75, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 347, 367, 355, 693, 379, 41, 131, 'Courier', 94, 18, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 348, 632, 305, 414, 959, 29, 80, 'Courier', 5, 95, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 349, 884, 392, 889, 377, 82, 75, 'Parcel_locker', 14, 138, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 350, 657, 692, 680, 623, 39, 20, 'Courier', 65, 61, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 351, 643, 550, 581, 737, 2, 51, 'Courier', 70, 39, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 352, 68, 588, 415, 547, 73, 106, 'Courier', 76, 65, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 353, 603, 977, 186, 228, 81, 100, 'Parcel_locker', 94, 48, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 354, 552, 880, 438, 224, 35, 25, 'Parcel_locker', 52, 137, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 355, 531, 812, 52, 249, 83, 82, 'Courier', 12, 132, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 356, 913, 583, 360, 243, 78, 54, 'Parcel_locker', 19, 149, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 357, 944, 425, 931, 462, 74, 99, 'Courier', 82, 76, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 358, 934, 907, 250, 962, 23, 43, 'Courier', 18, 74, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 359, 173, 927, 9, 420, 31, 49, 'Courier', 30, 93, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 360, 166, 308, 594, 24, 12, 93, 'Place', 62, 68, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 361, 922, 647, 72, 198, 5, 29, 'Courier', 90, 128, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 362, 996, 601, 66, 391, 7, 114, 'Place', 38, 122, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 363, 737, 634, 668, 839, 97, 124, 'Parcel_locker', 12, 75, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 364, 819, 140, 367, 498, 32, 22, 'Courier', 49, 132, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 365, 582, 647, 292, 517, 75, 6, 'Place', 46, 55, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 366, 448, 224, 299, 671, 60, 59, 'Courier', 80, 80, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 367, 414, 347, 703, 480, 62, 50, 'Courier', 90, 149, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 368, 466, 600, 888, 331, 86, 68, 'Place', 26, 8, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 369, 669, 900, 156, 438, 87, 107, 'Courier', 3, 12, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 370, 312, 327, 988, 298, 15, 100, 'Place', 64, 19, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 371, 888, 358, 535, 419, 96, 63, 'Courier', 49, 50, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 372, 722, 383, 163, 60, 33, 39, 'Courier', 40, 114, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 373, 721, 405, 177, 38, 57, 122, 'Parcel_locker', 33, 86, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 374, 521, 815, 717, 227, 30, 91, 'Courier', 100, 84, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 375, 967, 230, 476, 705, 76, 132, 'Place', 63, 38, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 376, 748, 588, 308, 909, 40, 95, 'Courier', 17, 63, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 377, 741, 979, 566, 503, 46, 121, 'Parcel_locker', 12, 150, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 378, 850, 577, 335, 124, 6, 84, 'Courier', 56, 109, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 379, 533, 753, 346, 313, 71, 146, 'Place', 45, 105, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 380, 268, 722, 237, 814, 9, 88, 'Place', 59, 113, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 381, 746, 71, 629, 422, 52, 70, 'Courier', 57, 38, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 382, 694, 479, 218, 908, 7, 8, 'Courier', 9, 14, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 383, 66, 987, 13, 145, 37, 117, 'Courier', 97, 75, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 384, 519, 592, 901, 446, 91, 77, 'Place', 30, 14, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 385, 811, 274, 453, 348, 15, 138, 'Place', 37, 17, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 386, 530, 290, 37, 769, 41, 5, 'Parcel_locker', 79, 36, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 387, 721, 641, 1, 801, 95, 11, 'Courier', 83, 68, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 388, 529, 389, 769, 669, 94, 49, 'Place', 55, 62, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 389, 629, 495, 540, 763, 74, 9, 'Parcel_locker', 41, 95, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 390, 712, 76, 955, 348, 2, 16, 'Courier', 93, 84, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 391, 357, 299, 985, 415, 33, 80, 'Parcel_locker', 11, 6, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 392, 931, 343, 873, 518, 84, 83, 'Place', 13, 34, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 393, 262, 684, 543, 840, 39, 124, 'Courier', 96, 22, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 394, 394, 941, 759, 846, 62, 78, 'Parcel_locker', 71, 111, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 395, 966, 733, 477, 199, 14, 40, 'Courier', 2, 147, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 396, 317, 128, 525, 506, 38, 29, 'Courier', 57, 44, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 397, 491, 896, 95, 86, 25, 130, 'Parcel_locker', 64, 66, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 398, 970, 553, 692, 387, 75, 6, 'Courier', 47, 106, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 399, 677, 900, 493, 454, 71, 20, 'Parcel_locker', 29, 73, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 400, 769, 771, 770, 766, 88, 109, 'Parcel_locker', 4, 64, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 401, 99, 439, 993, 759, 51, 50, 'Courier', 69, 113, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 402, 420, 737, 631, 104, 82, 21, 'Courier', 49, 7, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 403, 876, 28, 311, 725, 55, 47, 'Parcel_locker', 79, 130, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 404, 776, 236, 749, 315, 79, 51, 'Courier', 24, 8, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 405, 500, 811, 707, 190, 84, 104, 'Courier', 99, 56, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 406, 326, 603, 844, 49, 19, 91, 'Courier', 78, 146, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 407, 7, 552, 704, 462, 11, 9, 'Place', 17, 127, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 408, 237, 970, 393, 505, 57, 59, 'Place', 74, 120, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 409, 362, 153, 223, 571, 62, 120, 'Place', 45, 58, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 410, 137, 54, 748, 221, 82, 121, 'Courier', 82, 74, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 411, 307, 608, 174, 6, 90, 87, 'Courier', 21, 148, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 412, 608, 665, 313, 551, 45, 136, 'Courier', 100, 127, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 413, 239, 992, 741, 486, 17, 88, 'Courier', 75, 141, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 414, 472, 239, 984, 705, 55, 145, 'Courier', 13, 149, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 415, 81, 164, 803, 998, 3, 144, 'Courier', 9, 117, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 416, 539, 192, 307, 886, 19, 84, 'Courier', 82, 104, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 417, 805, 93, 664, 516, 31, 15, 'Parcel_locker', 51, 86, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 418, 850, 531, 637, 168, 48, 103, 'Courier', 28, 81, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 419, 94, 878, 284, 309, 3, 2, 'Parcel_locker', 4, 57, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 420, 565, 176, 639, 955, 12, 60, 'Parcel_locker', 84, 11, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 421, 947, 374, 565, 520, 82, 2, 'Parcel_locker', 63, 85, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 422, 275, 811, 632, 739, 81, 86, 'Parcel_locker', 6, 20, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 423, 339, 242, 607, 435, 66, 19, 'Parcel_locker', 20, 106, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 424, 480, 957, 131, 2, 76, 140, 'Courier', 59, 79, 'Place', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 425, 860, 941, 581, 779, 62, 81, 'Parcel_locker', 70, 8, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 426, 520, 465, 150, 574, 92, 33, 'Courier', 62, 128, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 427, 721, 585, 630, 856, 47, 59, 'Courier', 55, 137, 'Place', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 428, 43, 749, 181, 338, 60, 3, 'Place', 18, 5, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 429, 279, 494, 756, 64, 83, 149, 'Courier', 67, 142, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 430, 777, 262, 434, 292, 68, 93, 'Courier', 73, 63, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 431, 195, 110, 472, 280, 47, 12, 'Courier', 87, 100, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 432, 592, 642, 958, 543, 55, 73, 'Place', 61, 95, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 433, 163, 527, 406, 799, 27, 61, 'Courier', 12, 61, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 434, 612, 434, 493, 790, 52, 79, 'Parcel_locker', 52, 27, 'Place', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 435, 487, 162, 270, 812, 30, 127, 'Courier', 76, 136, 'Parcel_locker', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 436, 917, 740, 466, 93, 8, 89, 'Courier', 57, 10, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 437, 472, 986, 481, 958, 41, 18, 'Parcel_locker', 71, 70, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 438, 768, 655, 26, 881, 54, 81, 'Place', 53, 129, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 439, 821, 595, 337, 47, 76, 129, 'Place', 65, 42, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 440, 516, 122, 587, 910, 46, 99, 'Parcel_locker', 25, 77, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 441, 148, 307, 254, 988, 35, 145, 'Courier', 73, 78, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 442, 444, 292, 343, 595, 91, 147, 'Courier', 83, 70, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 443, 18, 236, 163, 801, 97, 29, 'Place', 75, 51, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 444, 959, 486, 977, 432, 79, 11, 'Parcel_locker', 50, 111, 'Courier', null);
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 445, 65, 38, 380, 91, 30, 140, 'Courier', 66, 116, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 446, 118, 249, 205, 986, 4, 121, 'Place', 28, 103, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 447, 900, 112, 41, 687, 72, 48, 'Courier', 13, 139, 'Courier', 'Normal');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 448, 617, 345, 436, 888, 81, 33, 'Parcel_locker', 40, 140, 'Courier', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 449, 492, 582, 552, 402, 47, 95, 'Parcel_locker', 31, 89, 'Parcel_locker', 'Special');
INSERT INTO ppl.parcels( id, weight, height, "length", width, sender_id, sender_address, sending_type, receiver_id, receiver_address, receiving_type, parcel_speed ) VALUES ( 450, 851, 969, 263, 732, 58, 2, 'Parcel_locker', 15, 100, 'Courier', 'Normal');
BEGIN;
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 8229, 'Place', 547);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 52, 'Place', 329);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 8334, 'Courier', 295);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 8380, 'Courier', 295);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 8385, 'Place', 375);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 13538, 'Place', 592);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 276, 'Parcel_locker', 1155);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 18931, 'Courier', 2);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 1812, 'Courier', 2);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 8540, 'Place', 453);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 446, 'Place', 577);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 13697, 'Place', 555);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 1927, 'Place', 508);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 624, 'Place', 539);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 8676, 'Courier', 117);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 13884, 'Courier', 15);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 869, 'Place', 562);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 9108, 'Place', 439);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 1016, 'Courier', 235);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 14165, 'Courier', 232);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 9238, 'Place', 394);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 2454, 'Place', 491);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 14340, 'Parcel_locker', 1010);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 1275, 'Courier', 235);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 14519, 'Courier', 289);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 2834, 'Place', 502);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 14642, 'Place', 399);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 3022, 'Place', 489);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 14965, 'Courier', 295);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 3324, 'Place', 558);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 15113, 'Parcel_locker', 1041);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 3359, 'Courier', 295);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 15304, 'Courier', 231);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 3548, 'Place', 459);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 3578, 'Place', 488);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 10350, 'Courier', 294);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6060, 'Courier', 97);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6143, 'Place', 497);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 3883, 'Place', 392);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6273, 'Parcel_locker', 1015);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 4122, 'Place', 331);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6426, 'Place', 485);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6525, 'Parcel_locker', 1017);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6632, 'Parcel_locker', 1092);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6634, 'Place', 305);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6676, 'Courier', 264);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 6695, 'Place', 591);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 4489, 'Parcel_locker', 1106);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 16286, 'Parcel_locker', 1018);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 4605, 'Place', 398);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 4682, 'Place', 477);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 16627, 'Place', 480);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 16629, 'Place', 378);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 7175, 'Courier', 65);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 4996, 'Courier', 220);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 4998, 'Courier', 188);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 7270, 'Courier', 172);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 5090, 'Courier', 207);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 7273, 'Place', 344);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 7381, 'Place', 369);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 17011, 'Courier', 229);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 17103, 'Courier', 232);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 17144, 'Place', 421);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 17257, 'Place', 418);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 7754, 'Courier', 125);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 5737, 'Courier', 2);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 17661, 'Courier', 164);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 8082, 'Parcel_locker', 1129);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 10912, 'Courier', 188);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 18128, 'Place', 420);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 10998, 'Place', 353);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 18425, 'Courier', 232);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 18450, 'Courier', 1);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 18519, 'Courier', 147);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 18715, 'Courier', 117);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 11614, 'Courier', 39);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 11736, 'Parcel_locker', 983);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 11980, 'Place', 480);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 12286, 'Place', 459);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 12557, 'Place', 331);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 12670, 'Place', 486);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 12991, 'Place', 412);
INSERT INTO ppl.status_info_given( id, type_to, to_whom ) VALUES ( 13005, 'Place', 427);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6059, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 51, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6142, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 18930, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6272, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 275, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6425, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 13537, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 1811, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 445, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6524, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 1926, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 13696, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6631, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6633, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6675, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 623, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 6694, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 13883, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 868, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 1015, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 2453, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 14164, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 7174, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 14339, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 7269, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 7272, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 1274, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 7380, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 14518, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 2833, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 14641, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 3021, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 7753, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 14964, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 3323, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 15112, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 3358, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 8081, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 15303, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 8228, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 3547, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 3577, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 8333, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 8379, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 8384, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 8539, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 3882, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 8675, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 4121, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 9107, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 16285, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 9237, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 4488, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 4604, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 16626, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 16628, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 4681, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 4995, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 4997, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 17010, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 5089, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 17102, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 17143, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 17256, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 10349, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 17660, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 5736, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 10911, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 18127, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 10997, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 18424, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 18449, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 18518, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 18714, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 11613, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 11735, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 11979, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 12285, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 12556, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 12669, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 12990, null);
INSERT INTO ppl.status_info_registered( id, id_place ) VALUES ( 13004, null);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6061, 'Parcel_locker', 1187);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 53, 'Place', 329);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 55, 'Storage', 800);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 57, 'Place', 327);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6144, 'Place', 497);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6146, 'Storage', 806);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6148, 'Parcel_locker', 1023);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6274, 'Parcel_locker', 1015);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6276, 'Storage', 754);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6278, 'Place', 505);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6427, 'Place', 485);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6429, 'Storage', 689);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6431, 'Place', 311);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 625, 'Place', 539);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 627, 'Storage', 758);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 629, 'Place', 454);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 13885, 'Parcel_locker', 996);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6635, 'Place', 305);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6637, 'Storage', 640);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 6639, 'Parcel_locker', 961);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 1017, 'Parcel_locker', 979);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 14520, 'Place', 491);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 7176, 'Place', 484);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 7271, 'Parcel_locker', 912);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 7274, 'Place', 344);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 7276, 'Storage', 771);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 7278, 'Place', 370);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 15114, 'Parcel_locker', 1041);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 15116, 'Storage', 783);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 15118, 'Parcel_locker', 1049);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 3325, 'Place', 558);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 3327, 'Storage', 833);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 3329, 'Place', 565);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 3360, 'Parcel_locker', 1066);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 8083, 'Parcel_locker', 1129);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 8085, 'Storage', 655);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 8087, 'Place', 327);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 9239, 'Place', 394);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 9241, 'Storage', 693);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 9243, 'Parcel_locker', 1120);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 17104, 'Parcel_locker', 968);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 4999, 'Place', 359);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 5091, 'Parcel_locker', 969);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 10351, 'Parcel_locker', 1076);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 10913, 'Place', 411);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 18520, 'Place', 358);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 18716, 'Parcel_locker', 1184);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 11615, 'Place', 560);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 12558, 'Place', 331);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 12560, 'Storage', 684);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 12562, 'Place', 413);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 12992, 'Place', 412);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 12994, 'Storage', 822);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 12996, 'Place', 508);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 13006, 'Place', 427);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 13008, 'Storage', 648);
INSERT INTO ppl.status_info_storage( id, type_storage, storage_id ) VALUES ( 13010, 'Place', 393);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 54, 236, 125, 'Place', 329, 'Storage', 800);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 56, 196, 180, 'Storage', 800, 'Place', 327);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6145, 166, 166, 'Place', 497, 'Storage', 806);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6147, 202, 140, 'Storage', 806, 'Parcel_locker', 1023);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6275, 7, 93, 'Parcel_locker', 1015, 'Storage', 754);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6277, 259, 158, 'Storage', 754, 'Place', 505);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 626, 5, 3, 'Place', 539, 'Storage', 758);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 628, 76, 264, 'Storage', 758, 'Place', 454);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6428, 211, 203, 'Place', 485, 'Storage', 689);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6430, 47, 192, 'Storage', 689, 'Place', 311);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6636, 4, 152, 'Place', 305, 'Storage', 640);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 6638, 109, 156, 'Storage', 640, 'Parcel_locker', 961);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 7275, 65, 21, 'Place', 344, 'Storage', 771);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 7277, 249, 166, 'Storage', 771, 'Place', 370);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 15115, 156, 181, 'Parcel_locker', 1041, 'Storage', 783);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 15117, 25, 89, 'Storage', 783, 'Parcel_locker', 1049);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 3326, 220, 229, 'Place', 558, 'Storage', 833);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 3328, 148, 254, 'Storage', 833, 'Place', 565);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 8084, 127, 6, 'Parcel_locker', 1129, 'Storage', 655);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 8086, 58, 219, 'Storage', 655, 'Place', 327);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 9240, 171, 41, 'Place', 394, 'Storage', 693);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 9242, 287, 54, 'Storage', 693, 'Parcel_locker', 1120);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 12559, 225, 59, 'Place', 331, 'Storage', 684);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 12561, 283, 55, 'Storage', 684, 'Place', 413);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 12993, 241, 297, 'Place', 412, 'Storage', 822);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 12995, 218, 127, 'Storage', 822, 'Place', 508);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 13007, 14, 293, 'Place', 427, 'Storage', 648);
INSERT INTO ppl.status_info_transit( id, courier_id, truck_id, type_from, id_from, type_where, id_to ) VALUES ( 13009, 254, 202, 'Storage', 648, 'Place', 393);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-11 02:51:26 AM', 60, 0, 6059);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-15 11:40:13 PM', 60, 1, 6060);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-19 03:38:19 AM', 60, 3, 6061);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-20 12:47:43 AM', 60, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-06 05:18:59 AM', 11, 0, 51);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-12 11:36:32 AM', 11, 1, 52);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-17 05:27:02 PM', 11, 3, 53);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-18 12:27:18 AM', 11, 2, 54);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-26 03:09:38 PM', 11, 3, 55);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-02-05 11:26:14 AM', 11, 2, 56);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-02-12 08:25:40 PM', 11, 3, 57);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-02-15 03:36:00 PM', 11, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-07-18 11:15:47 PM', 77, 0, 6142);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-07-22 05:21:25 PM', 77, 1, 6143);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-07-24 01:47:08 PM', 77, 3, 6144);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-05 08:37:49 AM', 77, 2, 6145);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-12 08:22:58 AM', 77, 3, 6146);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-20 12:11:52 PM', 77, 2, 6147);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-26 04:47:07 AM', 77, 3, 6148);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-09-05 10:13:12 AM', 77, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-10-14 02:47:35 AM', 352, 0, 18930);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-10-24 09:28:43 PM', 352, 1, 18931);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-11-07 08:35:10 PM', 352, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-04-25 12:14:48 AM', 105, 0, 6272);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-05-05 11:58:49 PM', 105, 1, 6273);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-05-09 05:03:09 AM', 105, 3, 6274);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-05-19 08:48:14 PM', 105, 2, 6275);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-05-27 12:30:57 PM', 105, 3, 6276);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-10 06:12:54 PM', 105, 2, 6277);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-14 09:17:14 PM', 105, 3, 6278);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-20 06:14:21 PM', 105, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-08 04:49:00 AM', 62, 0, 275);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-13 02:19:14 AM', 62, 1, 276);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-23 04:53:16 AM', 62, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-06-13 04:48:11 AM', 139, 0, 6425);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-06-20 10:59:33 PM', 139, 1, 6426);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-03 02:37:01 PM', 139, 3, 6427);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-01-13 08:17:30 AM', 418, 0, 1811);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-01-23 04:46:04 AM', 418, 1, 1812);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-02-05 11:11:35 AM', 418, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-10 05:07:50 PM', 139, 2, 6428);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-21 02:55:15 AM', 139, 3, 6429);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-24 12:16:07 PM', 139, 2, 6430);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-08-06 11:06:05 PM', 139, 3, 6431);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-08-16 11:29:19 PM', 139, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-01-12 08:47:52 PM', 104, 0, 445);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-01-13 08:45:28 AM', 104, 1, 446);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-01-20 04:53:01 AM', 104, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-06-25 01:35:10 AM', 439, 0, 13537);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-07-03 06:40:34 PM', 439, 1, 13538);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-07-05 11:33:49 AM', 439, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-02-13 01:43:38 AM', 443, 0, 1926);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-02-22 03:41:28 AM', 443, 1, 1927);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-03-04 07:58:39 PM', 443, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-02-02 04:00:03 AM', 163, 0, 6524);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-02-13 05:08:21 AM', 163, 1, 6525);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-02-13 08:19:23 AM', 163, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-06-10 04:00:46 AM', 145, 0, 623);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-06-11 08:32:05 AM', 145, 1, 624);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-06-14 05:17:11 PM', 145, 3, 625);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-06-21 06:34:57 PM', 145, 2, 626);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-07-04 03:53:57 AM', 145, 3, 627);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-07-08 12:31:22 AM', 145, 2, 628);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-07-13 04:47:21 AM', 145, 3, 629);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-07-22 05:11:33 PM', 145, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-01-03 05:32:44 AM', 188, 0, 6631);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-01-04 08:58:38 AM', 188, 1, 6632);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-01-07 05:20:46 PM', 188, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-10-18 07:24:29 AM', 189, 0, 6633);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-10-25 05:49:22 AM', 189, 1, 6634);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-11-05 10:16:51 PM', 189, 3, 6635);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-11-09 01:46:17 AM', 189, 2, 6636);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-11-11 12:11:56 AM', 189, 3, 6637);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-11-16 08:55:35 PM', 189, 2, 6638);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-11-17 06:34:49 AM', 189, 3, 6639);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-11-25 12:30:43 AM', 189, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-04-14 07:17:46 PM', 25, 0, 13696);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-04-18 08:01:01 PM', 25, 1, 13697);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-04-24 10:50:13 AM', 25, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-10-26 11:08:44 AM', 197, 0, 6675);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-11-03 06:58:01 AM', 197, 1, 6676);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-11-08 02:07:52 PM', 197, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-11-13 04:44:32 AM', 203, 0, 6694);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-11-14 12:22:28 PM', 203, 1, 6695);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-11-23 07:04:34 AM', 203, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-11-05 06:03:07 PM', 64, 0, 13883);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-11-11 07:31:52 PM', 64, 1, 13884);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-11-22 11:12:23 AM', 64, 3, 13885);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-11-25 02:38:23 PM', 64, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-06 08:58:11 AM', 200, 0, 868);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-06 01:11:03 PM', 200, 1, 869);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-12 04:51:39 PM', 200, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-01-21 12:33:34 PM', 232, 0, 1015);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-04 06:56:03 AM', 232, 1, 1016);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-08 03:44:00 PM', 232, 3, 1017);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-19 12:22:18 PM', 232, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-14 02:48:27 PM', 106, 0, 2453);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-25 01:01:47 AM', 106, 1, 2454);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-01-25 08:22:06 PM', 106, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-09-19 07:36:56 PM', 137, 0, 14164);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-09-26 05:24:05 AM', 137, 1, 14165);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-09-26 11:29:29 AM', 137, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-03-28 11:17:12 AM', 294, 0, 1274);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-04-11 03:24:49 AM', 294, 1, 1275);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-04-20 06:15:35 PM', 294, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-03 01:04:04 AM', 175, 0, 14339);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-04 09:10:32 PM', 175, 1, 14340);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-07 04:29:56 AM', 175, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-05-06 06:59:52 PM', 192, 0, 2833);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-05-15 12:27:26 PM', 192, 1, 2834);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-05-16 08:00:35 AM', 192, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-04-05 11:07:36 AM', 218, 0, 14518);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-04-09 09:21:14 PM', 218, 1, 14519);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-04-16 12:18:41 AM', 218, 3, 14520);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-04-24 07:21:33 AM', 218, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-06-07 02:36:15 PM', 249, 0, 14641);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-06-09 07:55:37 AM', 249, 1, 14642);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-06-09 06:09:37 PM', 249, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-06-04 05:45:23 PM', 230, 0, 3021);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-06-14 03:35:26 AM', 230, 1, 3022);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-06-17 11:03:25 AM', 230, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-02-08 01:48:42 PM', 311, 0, 7174);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-02-18 10:55:33 AM', 311, 1, 7175);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-02-24 06:24:26 AM', 311, 3, 7176);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-03-07 03:19:12 AM', 311, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-12 03:09:49 AM', 334, 0, 7269);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-19 07:49:13 AM', 334, 1, 7270);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-22 10:25:17 AM', 334, 3, 7271);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-24 09:20:54 PM', 334, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-06-25 05:55:02 AM', 335, 0, 7272);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-07-07 01:36:46 PM', 335, 1, 7273);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-07-08 06:26:23 AM', 335, 3, 7274);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-07-08 06:27:23 AM', 335, 2, 7275);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-07-17 04:12:53 AM', 335, 3, 7276);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-07-27 05:22:41 PM', 335, 2, 7277);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-08-04 04:58:43 AM', 335, 3, 7278);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-08-14 01:27:03 PM', 335, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-10-02 12:00:31 AM', 324, 0, 14964);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-10-04 10:38:17 AM', 324, 1, 14965);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-10-04 01:16:11 PM', 324, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-07-28 06:53:59 PM', 307, 0, 3323);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-07 08:55:52 PM', 307, 1, 3324);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-13 03:08:13 AM', 307, 3, 3325);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-13 11:28:19 AM', 307, 2, 3326);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-24 01:18:08 PM', 307, 3, 3327);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-09-05 09:25:20 AM', 307, 2, 3328);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-09-16 01:52:30 PM', 307, 3, 3329);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-09-27 02:20:04 PM', 307, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-09-12 06:53:33 AM', 316, 0, 3358);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-09-13 06:56:26 PM', 316, 1, 3359);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-09-20 04:15:39 PM', 316, 3, 3360);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-09-24 09:15:09 PM', 316, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-08-08 10:59:58 PM', 360, 0, 7380);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-08-10 07:46:07 AM', 360, 1, 7381);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-08-20 06:48:10 AM', 360, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-01 02:00:15 PM', 356, 0, 15112);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-07 07:07:01 AM', 356, 1, 15113);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-12 05:49:26 PM', 356, 3, 15114);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-22 11:01:34 AM', 356, 2, 15115);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-06-05 03:09:58 AM', 356, 3, 15116);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-06-13 08:52:10 AM', 356, 2, 15117);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-06-14 03:31:36 AM', 356, 3, 15118);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-06-15 09:49:52 PM', 356, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-01-27 11:28:25 AM', 362, 0, 3547);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-09 12:02:18 AM', 362, 1, 3548);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-18 11:12:14 PM', 362, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-08-23 12:27:09 AM', 370, 0, 3577);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-09-03 07:18:32 AM', 370, 1, 3578);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-09-10 02:54:31 AM', 370, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-09-28 11:26:37 AM', 395, 0, 15303);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-10-11 06:41:35 AM', 395, 1, 15304);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-10-17 04:57:25 PM', 395, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-01-01 03:05:25 PM', 442, 0, 7753);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-01-12 10:25:38 PM', 442, 1, 7754);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-01-15 03:54:17 AM', 442, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-05 07:14:35 PM', 446, 0, 3882);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-09 04:58:35 AM', 446, 1, 3883);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-15 12:14:08 AM', 446, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-03-24 06:32:15 AM', 66, 0, 8081);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-03-25 08:15:22 PM', 66, 1, 8082);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-04-08 01:56:18 PM', 66, 3, 8083);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-04-08 03:18:19 PM', 66, 2, 8084);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-04-10 04:18:23 PM', 66, 3, 8085);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-04-16 05:29:21 PM', 66, 2, 8086);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-04-22 12:26:55 AM', 66, 3, 8087);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-05-03 06:40:02 AM', 66, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-01-22 09:39:34 AM', 98, 0, 8228);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-03-22 09:53:39 AM', 58, 0, 4121);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-03-24 04:25:56 PM', 58, 1, 4122);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-04-04 03:27:36 AM', 58, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-01-25 02:11:32 PM', 98, 1, 8229);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-02-05 01:24:18 AM', 98, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-10-22 06:59:59 PM', 123, 0, 8333);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-10-26 04:07:00 AM', 123, 1, 8334);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-11-09 11:49:01 AM', 123, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-04-03 01:30:44 AM', 133, 0, 8379);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-04-11 09:09:50 AM', 133, 1, 8380);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-04-19 09:13:00 PM', 133, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-05-02 08:00:05 PM', 135, 0, 8384);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-05-08 06:34:11 PM', 135, 1, 8385);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-05-13 08:52:39 AM', 135, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-10 05:19:00 PM', 177, 0, 16285);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-13 02:22:59 PM', 177, 1, 16286);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-24 06:03:49 AM', 177, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-06-15 05:13:20 AM', 172, 0, 8539);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-06-25 04:36:03 PM', 172, 1, 8540);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-06-27 08:07:12 AM', 172, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-06-13 11:28:42 PM', 150, 0, 4488);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-06-24 11:17:05 PM', 150, 1, 4489);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-07-03 09:13:44 AM', 150, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-07-04 01:12:36 PM', 209, 0, 8675);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-07-14 06:57:54 PM', 209, 1, 8676);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-07-25 07:15:48 PM', 209, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-12-27 11:20:32 PM', 179, 0, 4604);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-01-06 07:46:18 AM', 179, 1, 4605);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-01-07 08:52:30 PM', 179, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-07 05:00:53 PM', 256, 0, 16626);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-15 05:51:54 AM', 256, 1, 16627);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2012-08-25 06:55:14 PM', 256, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-04-26 06:54:40 AM', 257, 0, 16628);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-05 11:09:45 PM', 257, 1, 16629);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-05-08 01:50:20 PM', 257, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-07-02 04:08:33 PM', 195, 0, 4681);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-07-12 06:43:08 PM', 195, 1, 4682);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2009-07-19 02:30:21 AM', 195, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-09-18 06:28:07 PM', 310, 0, 9107);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-09-20 01:41:06 PM', 310, 1, 9108);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-09-26 02:50:50 AM', 310, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-03-22 05:22:32 PM', 265, 0, 4995);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-03 07:17:07 AM', 265, 1, 4996);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-07 05:10:38 PM', 265, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-05-04 08:22:09 AM', 266, 0, 4997);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-05-04 10:52:38 PM', 266, 1, 4998);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-05-12 12:24:23 PM', 266, 3, 4999);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-05-18 08:33:13 PM', 266, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-06-07 05:37:56 PM', 350, 0, 17010);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-06-18 06:43:48 AM', 350, 1, 17011);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-06-22 10:50:20 AM', 350, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-06-01 11:45:22 AM', 342, 0, 9237);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-06-03 06:30:26 PM', 342, 1, 9238);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-06-08 08:51:38 AM', 342, 3, 9239);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-06-11 06:39:13 AM', 342, 2, 9240);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-06-22 05:50:08 PM', 342, 3, 9241);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-07-03 02:12:30 AM', 342, 2, 9242);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-07-10 08:31:32 AM', 342, 3, 9243);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-07-12 09:30:20 AM', 342, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-04-04 02:44:19 AM', 287, 0, 5089);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-04-10 12:13:05 PM', 287, 1, 5090);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-04-17 11:29:11 AM', 287, 3, 5091);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-04-23 12:36:38 PM', 287, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-06-01 08:29:14 PM', 374, 0, 17102);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-06-10 06:54:10 PM', 374, 1, 17103);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-06-12 05:24:46 AM', 374, 3, 17104);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-06-18 10:42:54 AM', 374, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-09-01 07:07:45 AM', 384, 0, 17143);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-09-01 07:50:20 PM', 384, 1, 17144);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-09-08 03:15:07 PM', 384, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-25 12:27:08 PM', 408, 0, 17256);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-27 09:15:30 AM', 408, 1, 17257);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-08-27 03:13:14 PM', 408, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-16 09:49:45 AM', 53, 0, 17660);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-21 06:58:55 AM', 53, 1, 17661);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-23 03:24:12 PM', 53, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-02-15 01:54:11 PM', 436, 0, 5736);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-02-16 11:11:17 PM', 436, 1, 5737);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2019-02-20 12:22:33 PM', 436, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-01 07:38:52 AM', 156, 0, 18127);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-01 09:17:55 AM', 156, 1, 18128);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-11 04:51:25 AM', 156, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-01-03 04:36:25 AM', 154, 0, 10349);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-01-14 12:56:04 AM', 154, 1, 10350);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-01-23 04:24:37 AM', 154, 3, 10351);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-01-27 02:56:20 PM', 154, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-08-08 05:04:02 AM', 235, 0, 18424);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-08-11 06:13:10 PM', 235, 1, 18425);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2011-08-15 07:36:16 PM', 235, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-15 01:00:25 PM', 240, 0, 18449);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-19 09:27:08 PM', 240, 1, 18450);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2008-04-22 01:49:27 PM', 240, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-07-17 11:23:12 AM', 254, 0, 18518);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-07-21 11:50:50 AM', 254, 1, 18519);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-07-23 07:12:43 AM', 254, 3, 18520);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-07-27 11:12:12 AM', 254, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-07 09:56:43 PM', 302, 0, 18714);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-09 06:01:12 AM', 302, 1, 18715);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-16 05:27:15 AM', 302, 3, 18716);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2010-02-16 12:04:23 PM', 302, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-04-07 06:45:35 PM', 295, 0, 10911);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-04-12 07:24:15 PM', 295, 1, 10912);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-04-16 12:16:25 AM', 295, 3, 10913);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2018-04-27 03:40:46 AM', 295, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-03 09:55:53 PM', 319, 0, 10997);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-08 12:59:37 AM', 319, 1, 10998);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2017-02-10 08:31:18 PM', 319, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-11-02 12:46:21 AM', 2, 0, 11613);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-11-05 08:36:36 PM', 2, 1, 11614);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-11-15 01:15:47 PM', 2, 3, 11615);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-11-20 06:47:16 AM', 2, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-03-02 07:45:21 AM', 31, 0, 11735);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-03-09 03:18:36 AM', 31, 1, 11736);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2022-03-19 02:53:59 AM', 31, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-09-24 10:08:10 PM', 88, 0, 11979);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-10-08 10:01:51 AM', 88, 1, 11980);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2016-10-12 11:03:38 PM', 88, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-10-28 02:39:47 PM', 153, 0, 12285);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-11-09 02:59:06 AM', 153, 1, 12286);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2013-11-16 08:18:47 PM', 153, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-03-03 08:01:45 AM', 216, 0, 12556);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-03-11 04:47:47 AM', 216, 1, 12557);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-03-15 05:53:54 PM', 216, 3, 12558);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-03-17 07:39:53 AM', 216, 2, 12559);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-03-20 11:40:19 PM', 216, 3, 12560);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-03-26 09:14:51 PM', 216, 2, 12561);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-04-07 09:11:15 AM', 216, 3, 12562);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2014-04-13 03:56:51 PM', 216, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-11-05 05:55:53 AM', 241, 0, 12669);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-11-15 10:35:44 PM', 241, 1, 12670);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2021-11-18 07:40:28 AM', 241, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-18 10:22:48 AM', 318, 0, 12990);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-18 10:46:25 AM', 318, 1, 12991);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-26 07:21:46 PM', 318, 3, 12992);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-07-27 07:20:28 PM', 318, 2, 12993);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-08-09 02:14:59 AM', 318, 3, 12994);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-08-10 05:19:01 AM', 318, 2, 12995);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-08-12 05:50:18 AM', 318, 3, 12996);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2015-08-18 02:55:19 PM', 318, 4, null);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-06 07:38:10 AM', 320, 0, 13004);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-14 02:10:41 AM', 320, 1, 13005);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-06-25 07:18:21 AM', 320, 3, 13006);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-07-06 04:09:15 AM', 320, 2, 13007);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-07-11 07:30:41 AM', 320, 3, 13008);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-07-12 01:41:20 AM', 320, 2, 13009);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-07-21 06:43:43 AM', 320, 3, 13010);
INSERT INTO ppl.parcel_history( "time", parcel_id, status_id, status_info_id ) VALUES ( '2020-07-23 01:04:34 PM', 320, 4, null);
COMMIT;