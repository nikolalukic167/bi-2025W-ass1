-- stg_006.tb_alert definition

-- Drop table

-- DROP TABLE stg_006.tb_alert;

CREATE TABLE stg_006.tb_alert (
	id int4 NOT NULL,
	alertname varchar(255) NOT NULL,
	colour varchar(255) NOT NULL,
	details varchar(255) NOT NULL,
	CONSTRAINT tb_alert_pkey PRIMARY KEY (id),
	CONSTRAINT uc_alert_alertname UNIQUE (alertname)
);


-- stg_006.tb_country definition

-- Drop table

-- DROP TABLE stg_006.tb_country;

CREATE TABLE stg_006.tb_country (
	id int4 NOT NULL,
	countryname varchar(255) NOT NULL,
	population int4 NOT NULL,
	CONSTRAINT tb_country_pkey PRIMARY KEY (id),
	CONSTRAINT uc_country_countryname UNIQUE (countryname)
);


-- stg_006.tb_param definition

-- Drop table

-- DROP TABLE stg_006.tb_param;

CREATE TABLE stg_006.tb_param (
	id int4 NOT NULL,
	paramname varchar(255) NOT NULL,
	category varchar(255) NOT NULL,
	purpose varchar(50) NOT NULL,
	unit varchar(255) NOT NULL,
	CONSTRAINT tb_param_category_check CHECK (((category)::text = ANY ((ARRAY['Particulate matter'::character varying, 'Gas'::character varying, 'Heavy Metal'::character varying, 'Volatile Organic Compound'::character varying, 'Biological'::character varying])::text[]))),
	CONSTRAINT tb_param_pkey PRIMARY KEY (id),
	CONSTRAINT tb_param_purpose_check CHECK (((purpose)::text = ANY ((ARRAY['Health Risk'::character varying, 'Comfort'::character varying, 'Environmental Monitoring'::character varying, 'Scientific Study'::character varying, 'Regulatory Compliance'::character varying])::text[]))),
	CONSTRAINT uc_param_paramname UNIQUE (paramname)
);


-- stg_006.tb_policy_initiative definition

-- Drop table

-- DROP TABLE stg_006.tb_policy_initiative;

CREATE TABLE stg_006.tb_policy_initiative (
	id int4 NOT NULL,
	"name" varchar(200) NOT NULL,
	region_scope varchar(100) NULL,
	start_date date NOT NULL,
	end_date date NULL,
	target_level varchar(20) NULL,
	notes varchar(500) NULL,
	CONSTRAINT tb_policy_initiative_pkey PRIMARY KEY (id)
);


-- stg_006.tb_readingmode definition

-- Drop table

-- DROP TABLE stg_006.tb_readingmode;

CREATE TABLE stg_006.tb_readingmode (
	id int4 NOT NULL,
	modename varchar(255) NOT NULL,
	latency int4 NOT NULL,
	validfrom date NOT NULL,
	validto date NULL,
	details varchar(255) NOT NULL,
	CONSTRAINT tb_readingmode_latency_check CHECK ((latency = ANY (ARRAY[1, 2, 5, 10]))),
	CONSTRAINT tb_readingmode_modename_check CHECK (((modename)::text = ANY ((ARRAY['Rapid'::character varying, 'Low Power'::character varying, 'Standard'::character varying, 'High Precision'::character varying])::text[]))),
	CONSTRAINT tb_readingmode_pkey PRIMARY KEY (id)
);


-- stg_006.tb_role definition

-- Drop table

-- DROP TABLE stg_006.tb_role;

CREATE TABLE stg_006.tb_role (
	id int4 NOT NULL,
	rolelevel int4 NOT NULL,
	category varchar(255) NOT NULL,
	rolename varchar(255) NOT NULL,
	CONSTRAINT tb_role_category_check CHECK (((category)::text = ANY ((ARRAY['Hardware'::character varying, 'Software'::character varying, 'Diagnostics'::character varying, 'Calibration'::character varying])::text[]))),
	CONSTRAINT tb_role_pkey PRIMARY KEY (id),
	CONSTRAINT tb_role_rolelevel_check CHECK ((rolelevel = ANY (ARRAY[1, 2, 3, 4]))),
	CONSTRAINT uc_role_rolename UNIQUE (rolename)
);


-- stg_006.tb_sensortype definition

-- Drop table

-- DROP TABLE stg_006.tb_sensortype;

CREATE TABLE stg_006.tb_sensortype (
	id int4 NOT NULL,
	typename varchar(255) NOT NULL,
	manufacturer varchar(255) NOT NULL,
	technology varchar(255) NOT NULL,
	CONSTRAINT tb_sensortype_manufacturer_check CHECK (((manufacturer)::text = ANY ((ARRAY['Sensirion'::character varying, 'Bosch'::character varying, 'Honeywell'::character varying, 'Other'::character varying])::text[]))),
	CONSTRAINT tb_sensortype_pkey PRIMARY KEY (id),
	CONSTRAINT tb_sensortype_technology_check CHECK (((technology)::text = ANY ((ARRAY['Optical'::character varying, 'Electrochemical'::character varying, 'Laser'::character varying])::text[])))
);


-- stg_006.tb_servicetype definition

-- Drop table

-- DROP TABLE stg_006.tb_servicetype;

CREATE TABLE stg_006.tb_servicetype (
	id int4 NOT NULL,
	typename varchar(255) NOT NULL,
	category varchar(255) NOT NULL,
	minlevel int4 NOT NULL,
	servicegroup varchar(255) NOT NULL,
	details varchar(255) NOT NULL,
	CONSTRAINT tb_servicetype_category_check CHECK (((category)::text = ANY ((ARRAY['Hardware'::character varying, 'Software'::character varying, 'Diagnostics'::character varying, 'Calibration'::character varying])::text[]))),
	CONSTRAINT tb_servicetype_minlevel_check CHECK ((minlevel = ANY (ARRAY[1, 2, 3, 4]))),
	CONSTRAINT tb_servicetype_pkey PRIMARY KEY (id)
);


-- stg_006.tb_city definition

-- Drop table

-- DROP TABLE stg_006.tb_city;

CREATE TABLE stg_006.tb_city (
	id int4 NOT NULL,
	countryid int4 NOT NULL,
	cityname varchar(255) NOT NULL,
	population int4 NOT NULL,
	latitude numeric(10, 4) NOT NULL,
	longitude numeric(10, 4) NOT NULL,
	CONSTRAINT tb_city_pkey PRIMARY KEY (id),
	CONSTRAINT uc_city_countryid_cityname UNIQUE (countryid, cityname),
	CONSTRAINT fk_city_countryid FOREIGN KEY (countryid) REFERENCES stg_006.tb_country(id)
);


-- stg_006.tb_employee definition

-- Drop table

-- DROP TABLE stg_006.tb_employee;

CREATE TABLE stg_006.tb_employee (
	id int4 NOT NULL,
	roleid int4 NOT NULL,
	badgenumber varchar(255) NOT NULL,
	validfrom date NOT NULL,
	validto date NULL,
	CONSTRAINT tb_employee_pkey PRIMARY KEY (id),
	CONSTRAINT fk_employee_roleid FOREIGN KEY (roleid) REFERENCES stg_006.tb_role(id)
);


-- stg_006.tb_paramalert definition

-- Drop table

-- DROP TABLE stg_006.tb_paramalert;

CREATE TABLE stg_006.tb_paramalert (
	id int4 NOT NULL,
	paramid int4 NOT NULL,
	alertid int4 NOT NULL,
	threshold numeric(10, 4) NOT NULL,
	CONSTRAINT tb_paramalert_pkey PRIMARY KEY (id),
	CONSTRAINT uc_param_alert UNIQUE (paramid, alertid),
	CONSTRAINT fk_paramalert_alertid FOREIGN KEY (alertid) REFERENCES stg_006.tb_alert(id),
	CONSTRAINT fk_paramalert_paramid FOREIGN KEY (paramid) REFERENCES stg_006.tb_param(id)
);


-- stg_006.tb_paramsensortype definition

-- Drop table

-- DROP TABLE stg_006.tb_paramsensortype;

CREATE TABLE stg_006.tb_paramsensortype (
	id int4 NOT NULL,
	sensortypeid int4 NOT NULL,
	paramid int4 NOT NULL,
	accuracy varchar(255) NOT NULL,
	CONSTRAINT tb_paramsensortype_accuracy_check CHECK (((accuracy)::text = ANY ((ARRAY['High'::character varying, 'Medium'::character varying, 'Low'::character varying])::text[]))),
	CONSTRAINT tb_paramsensortype_pkey PRIMARY KEY (id),
	CONSTRAINT uc_param_sensortype UNIQUE (paramid, sensortypeid),
	CONSTRAINT fk_paramsensortype_paramid FOREIGN KEY (paramid) REFERENCES stg_006.tb_param(id),
	CONSTRAINT fk_paramsensortype_sensortypeid FOREIGN KEY (sensortypeid) REFERENCES stg_006.tb_sensortype(id)
);


-- stg_006.tb_policy_initiative_city definition

-- Drop table

-- DROP TABLE stg_006.tb_policy_initiative_city;

CREATE TABLE stg_006.tb_policy_initiative_city (
	policy_initiative_id int4 NOT NULL,
	cityid int4 NOT NULL,
	priority int4 NULL,
	effective_from date NOT NULL,
	effective_to date NULL,
	CONSTRAINT tb_policy_initiative_city_pkey PRIMARY KEY (policy_initiative_id, cityid, effective_from),
	CONSTRAINT tb_policy_initiative_city_cityid_fkey FOREIGN KEY (cityid) REFERENCES stg_006.tb_city(id),
	CONSTRAINT tb_policy_initiative_city_policy_initiative_id_fkey FOREIGN KEY (policy_initiative_id) REFERENCES stg_006.tb_policy_initiative(id)
);


-- stg_006.tb_sensordevice definition

-- Drop table

-- DROP TABLE stg_006.tb_sensordevice;

CREATE TABLE stg_006.tb_sensordevice (
	id int4 NOT NULL,
	sensortypeid int4 NOT NULL,
	cityid int4 NOT NULL,
	locationname varchar(255) NOT NULL,
	locationtype varchar(255) NOT NULL,
	altitude int4 NOT NULL,
	installedat date NOT NULL,
	CONSTRAINT tb_sensordevice_locationtype_check CHECK (((locationtype)::text = ANY ((ARRAY['Urban'::character varying, 'Suburban'::character varying, 'Industrial'::character varying, 'Other'::character varying])::text[]))),
	CONSTRAINT tb_sensordevice_pkey PRIMARY KEY (id),
	CONSTRAINT fk_sensordevice_cityid FOREIGN KEY (cityid) REFERENCES stg_006.tb_city(id),
	CONSTRAINT fk_sensordevice_sensortypeid FOREIGN KEY (sensortypeid) REFERENCES stg_006.tb_sensortype(id)
);


-- stg_006.tb_serviceevent definition

-- Drop table

-- DROP TABLE stg_006.tb_serviceevent;

CREATE TABLE stg_006.tb_serviceevent (
	id int4 NOT NULL,
	servicetypeid int4 NOT NULL,
	employeeid int4 NOT NULL,
	sensordevid int4 NOT NULL,
	servicedat date NOT NULL,
	servicecost int4 NOT NULL,
	durationminutes int4 NOT NULL,
	servicequality int4 NOT NULL,
	CONSTRAINT tb_serviceevent_durationminutes_check CHECK ((durationminutes >= 0)),
	CONSTRAINT tb_serviceevent_pkey PRIMARY KEY (id),
	CONSTRAINT tb_serviceevent_servicecost_check CHECK ((servicecost >= 0)),
	CONSTRAINT tb_serviceevent_servicequality_check CHECK (((servicequality >= 1) AND (servicequality <= 5))),
	CONSTRAINT fk_serviceevent_employeeid FOREIGN KEY (employeeid) REFERENCES stg_006.tb_employee(id),
	CONSTRAINT fk_serviceevent_sensordevid FOREIGN KEY (sensordevid) REFERENCES stg_006.tb_sensordevice(id),
	CONSTRAINT fk_serviceevent_servicetypeid FOREIGN KEY (servicetypeid) REFERENCES stg_006.tb_servicetype(id)
);


-- stg_006.tb_weather definition

-- Drop table

-- DROP TABLE stg_006.tb_weather;

CREATE TABLE stg_006.tb_weather (
	id int4 NOT NULL,
	cityid int4 NOT NULL,
	observedat date NOT NULL,
	tempdaymin numeric(6, 1) NULL,
	tempdaymax numeric(6, 1) NULL,
	tempdayavg numeric(6, 1) NULL,
	precipmm numeric(6, 1) NULL,
	pressure numeric(6, 1) NULL,
	windspeed numeric(6, 1) NULL,
	windgusts numeric(6, 1) NULL,
	CONSTRAINT tb_weather_pkey PRIMARY KEY (id),
	CONSTRAINT uc_city_observedat UNIQUE (cityid, observedat),
	CONSTRAINT fk_weather_cityid FOREIGN KEY (cityid) REFERENCES stg_006.tb_city(id)
);


-- stg_006.tb_readingevent definition

-- Drop table

-- DROP TABLE stg_006.tb_readingevent;

CREATE TABLE stg_006.tb_readingevent (
	id int4 NOT NULL,
	sensordevid int4 NOT NULL,
	paramid int4 NOT NULL,
	readingmodeid int4 NOT NULL,
	readat date NOT NULL,
	recordedvalue numeric(10, 4) NOT NULL,
	datavolumekb int4 NOT NULL,
	dataquality int4 NOT NULL,
	CONSTRAINT tb_readingevent_dataquality_check CHECK (((dataquality >= 1) AND (dataquality <= 5))),
	CONSTRAINT tb_readingevent_pkey PRIMARY KEY (id),
	CONSTRAINT fk_readingevent_paramid FOREIGN KEY (paramid) REFERENCES stg_006.tb_param(id),
	CONSTRAINT fk_readingevent_readingmodeid FOREIGN KEY (readingmodeid) REFERENCES stg_006.tb_readingmode(id),
	CONSTRAINT fk_readingevent_sensordevid FOREIGN KEY (sensordevid) REFERENCES stg_006.tb_sensordevice(id)
);