toc.dat                                                                                             0000600 0004000 0002000 00000203016 13761310104 0014435 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP           %            
    x            delux    12.4    12.4 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false         �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false         �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false         �           1262    50712    delux    DATABASE     �   CREATE DATABASE delux WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Colombia.1252' LC_CTYPE = 'Spanish_Colombia.1252';
    DROP DATABASE delux;
                postgres    false                     2615    50713    delux    SCHEMA        CREATE SCHEMA delux;
    DROP SCHEMA delux;
                postgres    false         	            2615    50714 	   seguridad    SCHEMA        CREATE SCHEMA seguridad;
    DROP SCHEMA seguridad;
                postgres    false         �            1255    50715    f_log_auditoriacl()    FUNCTION     �  CREATE FUNCTION seguridad.f_log_auditoriacl() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
		_pk TEXT :='';		-- Representa la llave primaria de la tabla que esta siedno modificada.
		_sql TEXT;		-- Variable para la creacion del procedured.
		_column_guia RECORD; 	-- Variable para el FOR guarda los nombre de las columnas.
		_column_key RECORD; 	-- Variable para el FOR guarda los PK de las columnas.
		_session TEXT;	-- Almacena el usuario que genera el cambio.
		_user_db TEXT;		-- Almacena el usuario de bd que genera la transaccion.
		_control INT;		-- Variabel de control par alas llaves primarias.
		_count_key INT = 0;	-- Cantidad de columnas pertenecientes al PK.
		_sql_insert TEXT;	-- Variable para la construcción del insert del json de forma dinamica.
		_sql_delete TEXT;	-- Variable para la construcción del delete del json de forma dinamica.
		_sql_update TEXT;	-- Variable para la construcción del update del json de forma dinamica.
		_new_data RECORD; 	-- Fila que representa los campos nuevos del registro.
		_old_data RECORD;	-- Fila que representa los campos viejos del registro.

	BEGIN

			-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		 IF (TG_OP = 'INSERT') THEN
			_new_data := NEW;
			_old_data := NEW;
		ELSEIF (TG_OP = 'UPDATE') THEN
			_new_data := NEW;
			_old_data := OLD;
		ELSE
			_new_data := OLD;
			_old_data := OLD;
		END IF;

		-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'id_cliente' ) > 0) THEN
			_pk := _new_data.id_cliente;
		ELSE
			_pk := '-1';
		END IF;

		-- Se valida que exista el campo modified_by
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'modificado') > 0) THEN
			_session := _new_data.modificado;
		ELSE
			_session := '';
		END IF;

		-- Se guarda el susuario de bd que genera la transaccion
		_user_db := (SELECT CURRENT_USER);

		-- Se evalua que exista el procedimeinto adecuado
		IF (SELECT COUNT(*) FROM seguridad.function_db_view acfdv WHERE acfdv.b_function = 'field_audit' AND acfdv.b_type_parameters = TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', character varying, character varying, character varying, text, character varying, text, text') > 0
			THEN
				-- Se realiza la invocación del procedured generado dinamivamente
				PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP, _session, _user_db , _pk, ''::text);
		ELSE
			-- Se empieza la construcción del Procedured generico
			_sql := 'CREATE OR REPLACE FUNCTION seguridad.field_audit( _data_new '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _data_old '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _accion character varying, _session text, _user_db character varying, _table_pk text, _init text)'
			|| ' RETURNS TEXT AS ''
'
			|| '
'
	|| '	DECLARE
'
	|| '		_column_data TEXT;
	 	_datos jsonb;
	 	
'
	|| '	BEGIN
			_datos = ''''{}'''';
';
			-- Se evalua si hay que actualizar la pk del registro de auditoria.
			IF _pk = '-1'
				THEN
					_sql := _sql
					|| '
		_column_data := ';

					-- Se genera el update con la clave pk de la tabla
					SELECT
						COUNT(isk.column_name)
					INTO
						_control
					FROM
						information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
					WHERE
						istc.table_schema = TG_TABLE_SCHEMA
					 AND	istc.table_name = TG_TABLE_NAME
					 AND	istc.constraint_type ilike '%primary%';

					-- Se agregan las columnas que componen la pk de la tabla.
					FOR _column_key IN SELECT
							isk.column_name
						FROM
							information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
						WHERE
							istc.table_schema = TG_TABLE_SCHEMA
						 AND	istc.table_name = TG_TABLE_NAME
						 AND	istc.constraint_type ilike '%primary%'
						ORDER BY 
							isk.ordinal_position  LOOP

						_sql := _sql || ' _data_new.' || _column_key.column_name;
						
						_count_key := _count_key + 1 ;
						
						IF _count_key < _control THEN
							_sql :=	_sql || ' || ' || ''''',''''' || ' ||';
						END IF;
					END LOOP;
				_sql := _sql || ';';
			END IF;

			_sql_insert:='
		IF _accion = ''''INSERT''''
			THEN
				';
			_sql_delete:='
		ELSEIF _accion = ''''DELETE''''
			THEN
				';
			_sql_update:='
		ELSE
			';

			-- Se genera el ciclo de agregado de columnas para el nuevo procedured
			FOR _column_guia IN SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME
				LOOP
						
					_sql_insert:= _sql_insert || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', '
					|| '_data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_insert:= _sql_insert
						||'::text';
					END IF;

					_sql_insert:= _sql_insert || ')::jsonb;
				';

					_sql_delete := _sql_delete || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_delete:= _sql_delete
						||'::text';
					END IF;

					_sql_delete:= _sql_delete || ')::jsonb;
				';

					_sql_update := _sql_update || 'IF _data_old.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || ' <> _data_new.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || '
				THEN _datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ', '''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', _data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ')::jsonb;
			END IF;
			';
			END LOOP;

			-- Se le agrega la parte final del procedured generico
			
			_sql:= _sql || _sql_insert || _sql_delete || _sql_update
			|| ' 
		END IF;

		INSERT INTO seguridad.auditoriacl
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			''''' || TG_TABLE_SCHEMA || ''''',
			''''' || TG_TABLE_NAME || ''''',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;'''
|| '
LANGUAGE plpgsql;';

			-- Se genera la ejecución de _sql, es decir se crea el nuevo procedured de forma generica.
			EXECUTE _sql;

		-- Se realiza la invocación del procedured generado dinamivamente
			PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP::character varying, _session, _user_db, _pk, ''::text);

		END IF;

		RETURN NULL;

END;
$$;
 -   DROP FUNCTION seguridad.f_log_auditoriacl();
    	   seguridad          postgres    false    9         �            1255    50717    f_log_auditoriaco()    FUNCTION     �  CREATE FUNCTION seguridad.f_log_auditoriaco() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
		_pk TEXT :='';		-- Representa la llave primaria de la tabla que esta siedno modificada.
		_sql TEXT;		-- Variable para la creacion del procedured.
		_column_guia RECORD; 	-- Variable para el FOR guarda los nombre de las columnas.
		_column_key RECORD; 	-- Variable para el FOR guarda los PK de las columnas.
		_session TEXT;	-- Almacena el usuario que genera el cambio.
		_user_db TEXT;		-- Almacena el usuario de bd que genera la transaccion.
		_control INT;		-- Variabel de control par alas llaves primarias.
		_count_key INT = 0;	-- Cantidad de columnas pertenecientes al PK.
		_sql_insert TEXT;	-- Variable para la construcción del insert del json de forma dinamica.
		_sql_delete TEXT;	-- Variable para la construcción del delete del json de forma dinamica.
		_sql_update TEXT;	-- Variable para la construcción del update del json de forma dinamica.
		_new_data RECORD; 	-- Fila que representa los campos nuevos del registro.
		_old_data RECORD;	-- Fila que representa los campos viejos del registro.

	BEGIN

			-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		 IF (TG_OP = 'INSERT') THEN
			_new_data := NEW;
			_old_data := NEW;
		ELSEIF (TG_OP = 'UPDATE') THEN
			_new_data := NEW;
			_old_data := OLD;
		ELSE
			_new_data := OLD;
			_old_data := OLD;
		END IF;

		-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'id_conductor' ) > 0) THEN
			_pk := _new_data.id_conductor;
		ELSE
			_pk := '-1';
		END IF;

		-- Se valida que exista el campo modified_by
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'modificado') > 0) THEN
			_session := _new_data.modificado;
		ELSE
			_session := '';
		END IF;

		-- Se guarda el susuario de bd que genera la transaccion
		_user_db := (SELECT CURRENT_USER);

		-- Se evalua que exista el procedimeinto adecuado
		IF (SELECT COUNT(*) FROM seguridad.function_db_view acfdv WHERE acfdv.b_function = 'field_audit' AND acfdv.b_type_parameters = TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', character varying, character varying, character varying, text, character varying, text, text') > 0
			THEN
				-- Se realiza la invocación del procedured generado dinamivamente
				PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP, _session, _user_db , _pk, ''::text);
		ELSE
			-- Se empieza la construcción del Procedured generico
			_sql := 'CREATE OR REPLACE FUNCTION seguridad.field_audit( _data_new '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _data_old '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _accion character varying, _session text, _user_db character varying, _table_pk text, _init text)'
			|| ' RETURNS TEXT AS ''
'
			|| '
'
	|| '	DECLARE
'
	|| '		_column_data TEXT;
	 	_datos jsonb;
	 	
'
	|| '	BEGIN
			_datos = ''''{}'''';
';
			-- Se evalua si hay que actualizar la pk del registro de auditoria.
			IF _pk = '-1'
				THEN
					_sql := _sql
					|| '
		_column_data := ';

					-- Se genera el update con la clave pk de la tabla
					SELECT
						COUNT(isk.column_name)
					INTO
						_control
					FROM
						information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
					WHERE
						istc.table_schema = TG_TABLE_SCHEMA
					 AND	istc.table_name = TG_TABLE_NAME
					 AND	istc.constraint_type ilike '%primary%';

					-- Se agregan las columnas que componen la pk de la tabla.
					FOR _column_key IN SELECT
							isk.column_name
						FROM
							information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
						WHERE
							istc.table_schema = TG_TABLE_SCHEMA
						 AND	istc.table_name = TG_TABLE_NAME
						 AND	istc.constraint_type ilike '%primary%'
						ORDER BY 
							isk.ordinal_position  LOOP

						_sql := _sql || ' _data_new.' || _column_key.column_name;
						
						_count_key := _count_key + 1 ;
						
						IF _count_key < _control THEN
							_sql :=	_sql || ' || ' || ''''',''''' || ' ||';
						END IF;
					END LOOP;
				_sql := _sql || ';';
			END IF;

			_sql_insert:='
		IF _accion = ''''INSERT''''
			THEN
				';
			_sql_delete:='
		ELSEIF _accion = ''''DELETE''''
			THEN
				';
			_sql_update:='
		ELSE
			';

			-- Se genera el ciclo de agregado de columnas para el nuevo procedured
			FOR _column_guia IN SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME
				LOOP
						
					_sql_insert:= _sql_insert || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', '
					|| '_data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_insert:= _sql_insert
						||'::text';
					END IF;

					_sql_insert:= _sql_insert || ')::jsonb;
				';

					_sql_delete := _sql_delete || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_delete:= _sql_delete
						||'::text';
					END IF;

					_sql_delete:= _sql_delete || ')::jsonb;
				';

					_sql_update := _sql_update || 'IF _data_old.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || ' <> _data_new.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || '
				THEN _datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ', '''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', _data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ')::jsonb;
			END IF;
			';
			END LOOP;

			-- Se le agrega la parte final del procedured generico
			
			_sql:= _sql || _sql_insert || _sql_delete || _sql_update
			|| ' 
		END IF;

		INSERT INTO seguridad.auditoriaco
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			''''' || TG_TABLE_SCHEMA || ''''',
			''''' || TG_TABLE_NAME || ''''',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;'''
|| '
LANGUAGE plpgsql;';

			-- Se genera la ejecución de _sql, es decir se crea el nuevo procedured de forma generica.
			EXECUTE _sql;

		-- Se realiza la invocación del procedured generado dinamivamente
			PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP::character varying, _session, _user_db, _pk, ''::text);

		END IF;

		RETURN NULL;

END;
$$;
 -   DROP FUNCTION seguridad.f_log_auditoriaco();
    	   seguridad          postgres    false    9         �            1259    50719    cliente    TABLE     Y  CREATE TABLE delux.cliente (
    id_cliente integer NOT NULL,
    nombre text NOT NULL,
    apellido text,
    fecha_de_nacimiento date NOT NULL,
    email text NOT NULL,
    usuario text NOT NULL,
    contrasena text NOT NULL,
    modificado text DEFAULT 'sistema'::text NOT NULL,
    sesion text,
    fecha_sancion timestamp with time zone
);
    DROP TABLE delux.cliente;
       delux         heap    postgres    false    4         �            1255    50726 a   field_audit(delux.cliente, delux.cliente, character varying, text, character varying, text, text)    FUNCTION     �  CREATE FUNCTION seguridad.field_audit(_data_new delux.cliente, _data_old delux.cliente, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text) RETURNS text
    LANGUAGE plpgsql
    AS $$

	DECLARE
		_column_data TEXT;
	 	_datos jsonb;
	 	
	BEGIN
			_datos = '{}';

		IF _accion = 'INSERT'
			THEN
				_datos := _datos || json_build_object('id_cliente_nuevo', _data_new.id_cliente)::jsonb;
				_datos := _datos || json_build_object('nombre_nuevo', _data_new.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_nuevo', _data_new.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_nuevo', _data_new.email)::jsonb;
				_datos := _datos || json_build_object('usuario_nuevo', _data_new.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_nuevo', _data_new.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_nuevo', _data_new.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_nuevo', _data_new.sesion)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
				
		ELSEIF _accion = 'DELETE'
			THEN
				_datos := _datos || json_build_object('id_cliente_anterior', _data_old.id_cliente)::jsonb;
				_datos := _datos || json_build_object('nombre_anterior', _data_old.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_anterior', _data_old.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_anterior', _data_old.email)::jsonb;
				_datos := _datos || json_build_object('usuario_anterior', _data_old.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_anterior', _data_old.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_anterior', _data_old.sesion)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion)::jsonb;
				
		ELSE
			IF _data_old.id_cliente <> _data_new.id_cliente
				THEN _datos := _datos || json_build_object('id_cliente_anterior', _data_old.id_cliente, 'id_cliente_nuevo', _data_new.id_cliente)::jsonb;
			END IF;
			IF _data_old.nombre <> _data_new.nombre
				THEN _datos := _datos || json_build_object('nombre_anterior', _data_old.nombre, 'nombre_nuevo', _data_new.nombre)::jsonb;
			END IF;
			IF _data_old.apellido <> _data_new.apellido
				THEN _datos := _datos || json_build_object('apellido_anterior', _data_old.apellido, 'apellido_nuevo', _data_new.apellido)::jsonb;
			END IF;
			IF _data_old.fecha_de_nacimiento <> _data_new.fecha_de_nacimiento
				THEN _datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento, 'fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
			END IF;
			IF _data_old.email <> _data_new.email
				THEN _datos := _datos || json_build_object('email_anterior', _data_old.email, 'email_nuevo', _data_new.email)::jsonb;
			END IF;
			IF _data_old.usuario <> _data_new.usuario
				THEN _datos := _datos || json_build_object('usuario_anterior', _data_old.usuario, 'usuario_nuevo', _data_new.usuario)::jsonb;
			END IF;
			IF _data_old.contrasena <> _data_new.contrasena
				THEN _datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena, 'contrasena_nuevo', _data_new.contrasena)::jsonb;
			END IF;
			IF _data_old.modificado <> _data_new.modificado
				THEN _datos := _datos || json_build_object('modificado_anterior', _data_old.modificado, 'modificado_nuevo', _data_new.modificado)::jsonb;
			END IF;
			IF _data_old.sesion <> _data_new.sesion
				THEN _datos := _datos || json_build_object('sesion_anterior', _data_old.sesion, 'sesion_nuevo', _data_new.sesion)::jsonb;
			END IF;
			IF _data_old.fecha_sancion <> _data_new.fecha_sancion
				THEN _datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion, 'fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
			END IF;
			 
		END IF;

		INSERT INTO seguridad.auditoriacl
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			'delux',
			'cliente',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;$$;
 �   DROP FUNCTION seguridad.field_audit(_data_new delux.cliente, _data_old delux.cliente, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text);
    	   seguridad          postgres    false    9    204    204         �            1259    50727 	   conductor    TABLE     �  CREATE TABLE delux.conductor (
    id_conductor integer NOT NULL,
    nombre text NOT NULL,
    apellido text,
    fecha_de_nacimiento date NOT NULL,
    email text NOT NULL,
    placa text NOT NULL,
    celular text NOT NULL,
    usuario text NOT NULL,
    contrasena text NOT NULL,
    modificado text DEFAULT 'sistema'::text NOT NULL,
    sesion text,
    id_estado integer NOT NULL,
    cedula text DEFAULT '1234567890'::text NOT NULL,
    fecha_sancion timestamp with time zone
);
    DROP TABLE delux.conductor;
       delux         heap    postgres    false    4         �            1255    50735 e   field_audit(delux.conductor, delux.conductor, character varying, text, character varying, text, text)    FUNCTION     v  CREATE FUNCTION seguridad.field_audit(_data_new delux.conductor, _data_old delux.conductor, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text) RETURNS text
    LANGUAGE plpgsql
    AS $$

	DECLARE
		_column_data TEXT;
	 	_datos jsonb;
	 	
	BEGIN
			_datos = '{}';

		IF _accion = 'INSERT'
			THEN
				_datos := _datos || json_build_object('id_conductor_nuevo', _data_new.id_conductor)::jsonb;
				_datos := _datos || json_build_object('nombre_nuevo', _data_new.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_nuevo', _data_new.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_nuevo', _data_new.email)::jsonb;
				_datos := _datos || json_build_object('placa_nuevo', _data_new.placa)::jsonb;
				_datos := _datos || json_build_object('celular_nuevo', _data_new.celular)::jsonb;
				_datos := _datos || json_build_object('usuario_nuevo', _data_new.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_nuevo', _data_new.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_nuevo', _data_new.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_nuevo', _data_new.sesion)::jsonb;
				_datos := _datos || json_build_object('id_estado_nuevo', _data_new.id_estado)::jsonb;
				_datos := _datos || json_build_object('cedula_nuevo', _data_new.cedula)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
				
		ELSEIF _accion = 'DELETE'
			THEN
				_datos := _datos || json_build_object('id_conductor_anterior', _data_old.id_conductor)::jsonb;
				_datos := _datos || json_build_object('nombre_anterior', _data_old.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_anterior', _data_old.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_anterior', _data_old.email)::jsonb;
				_datos := _datos || json_build_object('placa_anterior', _data_old.placa)::jsonb;
				_datos := _datos || json_build_object('celular_anterior', _data_old.celular)::jsonb;
				_datos := _datos || json_build_object('usuario_anterior', _data_old.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_anterior', _data_old.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_anterior', _data_old.sesion)::jsonb;
				_datos := _datos || json_build_object('id_estado_anterior', _data_old.id_estado)::jsonb;
				_datos := _datos || json_build_object('cedula_anterior', _data_old.cedula)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion)::jsonb;
				
		ELSE
			IF _data_old.id_conductor <> _data_new.id_conductor
				THEN _datos := _datos || json_build_object('id_conductor_anterior', _data_old.id_conductor, 'id_conductor_nuevo', _data_new.id_conductor)::jsonb;
			END IF;
			IF _data_old.nombre <> _data_new.nombre
				THEN _datos := _datos || json_build_object('nombre_anterior', _data_old.nombre, 'nombre_nuevo', _data_new.nombre)::jsonb;
			END IF;
			IF _data_old.apellido <> _data_new.apellido
				THEN _datos := _datos || json_build_object('apellido_anterior', _data_old.apellido, 'apellido_nuevo', _data_new.apellido)::jsonb;
			END IF;
			IF _data_old.fecha_de_nacimiento <> _data_new.fecha_de_nacimiento
				THEN _datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento, 'fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
			END IF;
			IF _data_old.email <> _data_new.email
				THEN _datos := _datos || json_build_object('email_anterior', _data_old.email, 'email_nuevo', _data_new.email)::jsonb;
			END IF;
			IF _data_old.placa <> _data_new.placa
				THEN _datos := _datos || json_build_object('placa_anterior', _data_old.placa, 'placa_nuevo', _data_new.placa)::jsonb;
			END IF;
			IF _data_old.celular <> _data_new.celular
				THEN _datos := _datos || json_build_object('celular_anterior', _data_old.celular, 'celular_nuevo', _data_new.celular)::jsonb;
			END IF;
			IF _data_old.usuario <> _data_new.usuario
				THEN _datos := _datos || json_build_object('usuario_anterior', _data_old.usuario, 'usuario_nuevo', _data_new.usuario)::jsonb;
			END IF;
			IF _data_old.contrasena <> _data_new.contrasena
				THEN _datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena, 'contrasena_nuevo', _data_new.contrasena)::jsonb;
			END IF;
			IF _data_old.modificado <> _data_new.modificado
				THEN _datos := _datos || json_build_object('modificado_anterior', _data_old.modificado, 'modificado_nuevo', _data_new.modificado)::jsonb;
			END IF;
			IF _data_old.sesion <> _data_new.sesion
				THEN _datos := _datos || json_build_object('sesion_anterior', _data_old.sesion, 'sesion_nuevo', _data_new.sesion)::jsonb;
			END IF;
			IF _data_old.id_estado <> _data_new.id_estado
				THEN _datos := _datos || json_build_object('id_estado_anterior', _data_old.id_estado, 'id_estado_nuevo', _data_new.id_estado)::jsonb;
			END IF;
			IF _data_old.cedula <> _data_new.cedula
				THEN _datos := _datos || json_build_object('cedula_anterior', _data_old.cedula, 'cedula_nuevo', _data_new.cedula)::jsonb;
			END IF;
			IF _data_old.fecha_sancion <> _data_new.fecha_sancion
				THEN _datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion, 'fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
			END IF;
			 
		END IF;

		INSERT INTO seguridad.auditoriaco
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			'delux',
			'conductor',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;$$;
 �   DROP FUNCTION seguridad.field_audit(_data_new delux.conductor, _data_old delux.conductor, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text);
    	   seguridad          postgres    false    205    205    9         �            1259    50736    administrador    TABLE     e   CREATE TABLE delux.administrador (
    id integer NOT NULL,
    usuario text,
    contrasena text
);
     DROP TABLE delux.administrador;
       delux         heap    postgres    false    4         �            1259    50742    administrador_id_seq    SEQUENCE     �   CREATE SEQUENCE delux.administrador_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE delux.administrador_id_seq;
       delux          postgres    false    4    206         �           0    0    administrador_id_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE delux.administrador_id_seq OWNED BY delux.administrador.id;
          delux          postgres    false    207         �            1259    50744    cliente_id_cliente_seq    SEQUENCE     �   CREATE SEQUENCE delux.cliente_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE delux.cliente_id_cliente_seq;
       delux          postgres    false    4    204         �           0    0    cliente_id_cliente_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE delux.cliente_id_cliente_seq OWNED BY delux.cliente.id_cliente;
          delux          postgres    false    208         �            1259    50746    conductor_id_conductor_seq    SEQUENCE     �   CREATE SEQUENCE delux.conductor_id_conductor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE delux.conductor_id_conductor_seq;
       delux          postgres    false    4    205         �           0    0    conductor_id_conductor_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE delux.conductor_id_conductor_seq OWNED BY delux.conductor.id_conductor;
          delux          postgres    false    209         �            1259    50748    destino    TABLE     s   CREATE TABLE delux.destino (
    id integer NOT NULL,
    lugar_destino text NOT NULL,
    lugar_ubicacion text
);
    DROP TABLE delux.destino;
       delux         heap    postgres    false    4         �            1259    50754    destino_id_seq    SEQUENCE     �   CREATE SEQUENCE delux.destino_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE delux.destino_id_seq;
       delux          postgres    false    210    4         �           0    0    destino_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE delux.destino_id_seq OWNED BY delux.destino.id;
          delux          postgres    false    211         �            1259    50756    estado    TABLE     P   CREATE TABLE delux.estado (
    id integer NOT NULL,
    disponibilidad text
);
    DROP TABLE delux.estado;
       delux         heap    postgres    false    4         �            1259    50762    estado_id_seq    SEQUENCE     �   CREATE SEQUENCE delux.estado_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE delux.estado_id_seq;
       delux          postgres    false    212    4         �           0    0    estado_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE delux.estado_id_seq OWNED BY delux.estado.id;
          delux          postgres    false    213         �            1259    50764    notificacion_de_servicio    TABLE     &  CREATE TABLE delux.notificacion_de_servicio (
    id_cliente integer NOT NULL,
    id integer NOT NULL,
    id_destino integer NOT NULL,
    id_ubicacion integer NOT NULL,
    descripcion_servicio text,
    tarifa double precision DEFAULT 100 NOT NULL,
    fecha_carrera timestamp with time zone,
    pago integer,
    kilometros double precision,
    estado text,
    conductor text,
    comentario_de_conductor text,
    fecha_fin_carrera timestamp with time zone,
    comentario_de_cliente text,
    id_conductor integer,
    conversacion text
);
 +   DROP TABLE delux.notificacion_de_servicio;
       delux         heap    postgres    false    4         �            1259    50771 '   notificacion de servicio_id_cliente_seq    SEQUENCE     �   CREATE SEQUENCE delux."notificacion de servicio_id_cliente_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE delux."notificacion de servicio_id_cliente_seq";
       delux          postgres    false    4    214         �           0    0 '   notificacion de servicio_id_cliente_seq    SEQUENCE OWNED BY     s   ALTER SEQUENCE delux."notificacion de servicio_id_cliente_seq" OWNED BY delux.notificacion_de_servicio.id_cliente;
          delux          postgres    false    215         �            1259    50773    notificacion de servicio_id_seq    SEQUENCE     �   CREATE SEQUENCE delux."notificacion de servicio_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE delux."notificacion de servicio_id_seq";
       delux          postgres    false    214    4         �           0    0    notificacion de servicio_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE delux."notificacion de servicio_id_seq" OWNED BY delux.notificacion_de_servicio.id;
          delux          postgres    false    216         �            1259    50775    pago    TABLE     T   CREATE TABLE delux.pago (
    id integer NOT NULL,
    descripcion text NOT NULL
);
    DROP TABLE delux.pago;
       delux         heap    postgres    false    4         �            1259    50781    pago_id_seq    SEQUENCE     �   CREATE SEQUENCE delux.pago_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE delux.pago_id_seq;
       delux          postgres    false    217    4         �           0    0    pago_id_seq    SEQUENCE OWNED BY     9   ALTER SEQUENCE delux.pago_id_seq OWNED BY delux.pago.id;
          delux          postgres    false    218         �            1259    50783    acceso_cliente    TABLE     �   CREATE TABLE seguridad.acceso_cliente (
    id integer NOT NULL,
    id_cliente integer NOT NULL,
    ip text NOT NULL,
    mac text NOT NULL,
    fecha_inicio timestamp without time zone NOT NULL,
    session text NOT NULL,
    fecha_fin text
);
 %   DROP TABLE seguridad.acceso_cliente;
    	   seguridad         heap    postgres    false    9         �            1259    50789    acceso_cliente_id_seq    SEQUENCE     �   CREATE SEQUENCE seguridad.acceso_cliente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE seguridad.acceso_cliente_id_seq;
    	   seguridad          postgres    false    219    9         �           0    0    acceso_cliente_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE seguridad.acceso_cliente_id_seq OWNED BY seguridad.acceso_cliente.id;
       	   seguridad          postgres    false    220         �            1259    50791    acceso_conductor    TABLE     �   CREATE TABLE seguridad.acceso_conductor (
    id integer NOT NULL,
    id_conductor integer NOT NULL,
    ip text NOT NULL,
    mac text NOT NULL,
    fecha_inicio timestamp without time zone NOT NULL,
    session text NOT NULL,
    fecha_fin text
);
 '   DROP TABLE seguridad.acceso_conductor;
    	   seguridad         heap    postgres    false    9         �            1259    50797    acceso_conductor_id_seq    SEQUENCE     �   CREATE SEQUENCE seguridad.acceso_conductor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE seguridad.acceso_conductor_id_seq;
    	   seguridad          postgres    false    9    221         �           0    0    acceso_conductor_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE seguridad.acceso_conductor_id_seq OWNED BY seguridad.acceso_conductor.id;
       	   seguridad          postgres    false    222         �            1259    50799    auditoriacl    TABLE     W  CREATE TABLE seguridad.auditoriacl (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    accion character varying(100),
    schema character varying(200) NOT NULL,
    tabla character varying(200),
    session text NOT NULL,
    user_bd character varying(100) NOT NULL,
    data jsonb NOT NULL,
    pk text NOT NULL
);
 "   DROP TABLE seguridad.auditoriacl;
    	   seguridad         heap    postgres    false    9         �           0    0    TABLE auditoriacl    COMMENT     d   COMMENT ON TABLE seguridad.auditoriacl IS 'Tabla que almacena la trazabilidad de la informaicón.';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.id    COMMENT     G   COMMENT ON COLUMN seguridad.auditoriacl.id IS 'campo pk de la tabla ';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.fecha    COMMENT     ]   COMMENT ON COLUMN seguridad.auditoriacl.fecha IS 'ALmacen ala la fecha de la modificación';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.accion    COMMENT     i   COMMENT ON COLUMN seguridad.auditoriacl.accion IS 'Almacena la accion que se ejecuto sobre el registro';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.schema    COMMENT     p   COMMENT ON COLUMN seguridad.auditoriacl.schema IS 'Almanena el nomnbre del schema de la tabla que se modifico';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.tabla    COMMENT     c   COMMENT ON COLUMN seguridad.auditoriacl.tabla IS 'Almacena el nombre de la tabla que se modifico';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.session    COMMENT     s   COMMENT ON COLUMN seguridad.auditoriacl.session IS 'Campo que almacena el id de la session que generó el cambio';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.user_bd    COMMENT     �   COMMENT ON COLUMN seguridad.auditoriacl.user_bd IS 'Campo que almacena el user que se autentico en el motor para generar el cmabio';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.data    COMMENT     g   COMMENT ON COLUMN seguridad.auditoriacl.data IS 'campo que almacena la modificaicón que se realizó';
       	   seguridad          postgres    false    223         �           0    0    COLUMN auditoriacl.pk    COMMENT     Z   COMMENT ON COLUMN seguridad.auditoriacl.pk IS 'Campo que identifica el id del registro.';
       	   seguridad          postgres    false    223         �            1259    50805    auditoriacl_id_seq    SEQUENCE     ~   CREATE SEQUENCE seguridad.auditoriacl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE seguridad.auditoriacl_id_seq;
    	   seguridad          postgres    false    223    9         �           0    0    auditoriacl_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE seguridad.auditoriacl_id_seq OWNED BY seguridad.auditoriacl.id;
       	   seguridad          postgres    false    224         �            1259    50807    auditoriaco    TABLE     W  CREATE TABLE seguridad.auditoriaco (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    accion character varying(100),
    schema character varying(200) NOT NULL,
    tabla character varying(200),
    session text NOT NULL,
    user_bd character varying(100) NOT NULL,
    data jsonb NOT NULL,
    pk text NOT NULL
);
 "   DROP TABLE seguridad.auditoriaco;
    	   seguridad         heap    postgres    false    9         �           0    0    TABLE auditoriaco    COMMENT     d   COMMENT ON TABLE seguridad.auditoriaco IS 'Tabla que almacena la trazabilidad de la informaicón.';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.id    COMMENT     G   COMMENT ON COLUMN seguridad.auditoriaco.id IS 'campo pk de la tabla ';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.fecha    COMMENT     ]   COMMENT ON COLUMN seguridad.auditoriaco.fecha IS 'ALmacen ala la fecha de la modificación';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.accion    COMMENT     i   COMMENT ON COLUMN seguridad.auditoriaco.accion IS 'Almacena la accion que se ejecuto sobre el registro';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.schema    COMMENT     p   COMMENT ON COLUMN seguridad.auditoriaco.schema IS 'Almanena el nomnbre del schema de la tabla que se modifico';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.tabla    COMMENT     c   COMMENT ON COLUMN seguridad.auditoriaco.tabla IS 'Almacena el nombre de la tabla que se modifico';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.session    COMMENT     s   COMMENT ON COLUMN seguridad.auditoriaco.session IS 'Campo que almacena el id de la session que generó el cambio';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.user_bd    COMMENT     �   COMMENT ON COLUMN seguridad.auditoriaco.user_bd IS 'Campo que almacena el user que se autentico en el motor para generar el cmabio';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.data    COMMENT     g   COMMENT ON COLUMN seguridad.auditoriaco.data IS 'campo que almacena la modificaicón que se realizó';
       	   seguridad          postgres    false    225         �           0    0    COLUMN auditoriaco.pk    COMMENT     Z   COMMENT ON COLUMN seguridad.auditoriaco.pk IS 'Campo que identifica el id del registro.';
       	   seguridad          postgres    false    225         �            1259    50813    auditoriaco_id_seq    SEQUENCE     ~   CREATE SEQUENCE seguridad.auditoriaco_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE seguridad.auditoriaco_id_seq;
    	   seguridad          postgres    false    225    9         �           0    0    auditoriaco_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE seguridad.auditoriaco_id_seq OWNED BY seguridad.auditoriaco.id;
       	   seguridad          postgres    false    226         �            1259    50815    function_db_view    VIEW     �  CREATE VIEW seguridad.function_db_view AS
 SELECT pp.proname AS b_function,
    oidvectortypes(pp.proargtypes) AS b_type_parameters
   FROM (pg_proc pp
     JOIN pg_namespace pn ON ((pn.oid = pp.pronamespace)))
  WHERE ((pn.nspname)::text <> ALL (ARRAY[('pg_catalog'::character varying)::text, ('information_schema'::character varying)::text, ('admin_control'::character varying)::text, ('vial'::character varying)::text]));
 &   DROP VIEW seguridad.function_db_view;
    	   seguridad          postgres    false    9         �            1259    50820    token_recuperacion    TABLE     �   CREATE TABLE seguridad.token_recuperacion (
    id integer NOT NULL,
    id_cliente integer NOT NULL,
    token text NOT NULL,
    creado timestamp without time zone,
    vigencia timestamp without time zone
);
 )   DROP TABLE seguridad.token_recuperacion;
    	   seguridad         heap    postgres    false    9         �            1259    50826    token_recuperacion_conductor    TABLE     �   CREATE TABLE seguridad.token_recuperacion_conductor (
    id integer NOT NULL,
    id_conductor integer NOT NULL,
    token text NOT NULL,
    creado timestamp with time zone NOT NULL,
    vigencia timestamp with time zone NOT NULL
);
 3   DROP TABLE seguridad.token_recuperacion_conductor;
    	   seguridad         heap    postgres    false    9         �            1259    50832 #   token_recuperacion_conductor_id_seq    SEQUENCE     �   CREATE SEQUENCE seguridad.token_recuperacion_conductor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE seguridad.token_recuperacion_conductor_id_seq;
    	   seguridad          postgres    false    9    229         �           0    0 #   token_recuperacion_conductor_id_seq    SEQUENCE OWNED BY     q   ALTER SEQUENCE seguridad.token_recuperacion_conductor_id_seq OWNED BY seguridad.token_recuperacion_conductor.id;
       	   seguridad          postgres    false    230         �            1259    50834    token_recuperacion_id_seq    SEQUENCE     �   CREATE SEQUENCE seguridad.token_recuperacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE seguridad.token_recuperacion_id_seq;
    	   seguridad          postgres    false    228    9         �           0    0    token_recuperacion_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE seguridad.token_recuperacion_id_seq OWNED BY seguridad.token_recuperacion.id;
       	   seguridad          postgres    false    231         �
           2604    50836    administrador id    DEFAULT     r   ALTER TABLE ONLY delux.administrador ALTER COLUMN id SET DEFAULT nextval('delux.administrador_id_seq'::regclass);
 >   ALTER TABLE delux.administrador ALTER COLUMN id DROP DEFAULT;
       delux          postgres    false    207    206         �
           2604    50837    cliente id_cliente    DEFAULT     v   ALTER TABLE ONLY delux.cliente ALTER COLUMN id_cliente SET DEFAULT nextval('delux.cliente_id_cliente_seq'::regclass);
 @   ALTER TABLE delux.cliente ALTER COLUMN id_cliente DROP DEFAULT;
       delux          postgres    false    208    204         �
           2604    50838    conductor id_conductor    DEFAULT     ~   ALTER TABLE ONLY delux.conductor ALTER COLUMN id_conductor SET DEFAULT nextval('delux.conductor_id_conductor_seq'::regclass);
 D   ALTER TABLE delux.conductor ALTER COLUMN id_conductor DROP DEFAULT;
       delux          postgres    false    209    205         �
           2604    50839 
   destino id    DEFAULT     f   ALTER TABLE ONLY delux.destino ALTER COLUMN id SET DEFAULT nextval('delux.destino_id_seq'::regclass);
 8   ALTER TABLE delux.destino ALTER COLUMN id DROP DEFAULT;
       delux          postgres    false    211    210         �
           2604    50840 	   estado id    DEFAULT     d   ALTER TABLE ONLY delux.estado ALTER COLUMN id SET DEFAULT nextval('delux.estado_id_seq'::regclass);
 7   ALTER TABLE delux.estado ALTER COLUMN id DROP DEFAULT;
       delux          postgres    false    213    212         �
           2604    50841 #   notificacion_de_servicio id_cliente    DEFAULT     �   ALTER TABLE ONLY delux.notificacion_de_servicio ALTER COLUMN id_cliente SET DEFAULT nextval('delux."notificacion de servicio_id_cliente_seq"'::regclass);
 Q   ALTER TABLE delux.notificacion_de_servicio ALTER COLUMN id_cliente DROP DEFAULT;
       delux          postgres    false    215    214         �
           2604    50842    notificacion_de_servicio id    DEFAULT     �   ALTER TABLE ONLY delux.notificacion_de_servicio ALTER COLUMN id SET DEFAULT nextval('delux."notificacion de servicio_id_seq"'::regclass);
 I   ALTER TABLE delux.notificacion_de_servicio ALTER COLUMN id DROP DEFAULT;
       delux          postgres    false    216    214         �
           2604    50843    pago id    DEFAULT     `   ALTER TABLE ONLY delux.pago ALTER COLUMN id SET DEFAULT nextval('delux.pago_id_seq'::regclass);
 5   ALTER TABLE delux.pago ALTER COLUMN id DROP DEFAULT;
       delux          postgres    false    218    217         �
           2604    50844    acceso_cliente id    DEFAULT     |   ALTER TABLE ONLY seguridad.acceso_cliente ALTER COLUMN id SET DEFAULT nextval('seguridad.acceso_cliente_id_seq'::regclass);
 C   ALTER TABLE seguridad.acceso_cliente ALTER COLUMN id DROP DEFAULT;
    	   seguridad          postgres    false    220    219         �
           2604    50845    acceso_conductor id    DEFAULT     �   ALTER TABLE ONLY seguridad.acceso_conductor ALTER COLUMN id SET DEFAULT nextval('seguridad.acceso_conductor_id_seq'::regclass);
 E   ALTER TABLE seguridad.acceso_conductor ALTER COLUMN id DROP DEFAULT;
    	   seguridad          postgres    false    222    221         �
           2604    50846    auditoriacl id    DEFAULT     v   ALTER TABLE ONLY seguridad.auditoriacl ALTER COLUMN id SET DEFAULT nextval('seguridad.auditoriacl_id_seq'::regclass);
 @   ALTER TABLE seguridad.auditoriacl ALTER COLUMN id DROP DEFAULT;
    	   seguridad          postgres    false    224    223         �
           2604    50847    auditoriaco id    DEFAULT     v   ALTER TABLE ONLY seguridad.auditoriaco ALTER COLUMN id SET DEFAULT nextval('seguridad.auditoriaco_id_seq'::regclass);
 @   ALTER TABLE seguridad.auditoriaco ALTER COLUMN id DROP DEFAULT;
    	   seguridad          postgres    false    226    225         �
           2604    50848    token_recuperacion id    DEFAULT     �   ALTER TABLE ONLY seguridad.token_recuperacion ALTER COLUMN id SET DEFAULT nextval('seguridad.token_recuperacion_id_seq'::regclass);
 G   ALTER TABLE seguridad.token_recuperacion ALTER COLUMN id DROP DEFAULT;
    	   seguridad          postgres    false    231    228         �
           2604    50849    token_recuperacion_conductor id    DEFAULT     �   ALTER TABLE ONLY seguridad.token_recuperacion_conductor ALTER COLUMN id SET DEFAULT nextval('seguridad.token_recuperacion_conductor_id_seq'::regclass);
 Q   ALTER TABLE seguridad.token_recuperacion_conductor ALTER COLUMN id DROP DEFAULT;
    	   seguridad          postgres    false    230    229         �          0    50736    administrador 
   TABLE DATA           ?   COPY delux.administrador (id, usuario, contrasena) FROM stdin;
    delux          postgres    false    206       2967.dat �          0    50719    cliente 
   TABLE DATA           �   COPY delux.cliente (id_cliente, nombre, apellido, fecha_de_nacimiento, email, usuario, contrasena, modificado, sesion, fecha_sancion) FROM stdin;
    delux          postgres    false    204       2965.dat �          0    50727 	   conductor 
   TABLE DATA           �   COPY delux.conductor (id_conductor, nombre, apellido, fecha_de_nacimiento, email, placa, celular, usuario, contrasena, modificado, sesion, id_estado, cedula, fecha_sancion) FROM stdin;
    delux          postgres    false    205       2966.dat �          0    50748    destino 
   TABLE DATA           D   COPY delux.destino (id, lugar_destino, lugar_ubicacion) FROM stdin;
    delux          postgres    false    210       2971.dat �          0    50756    estado 
   TABLE DATA           3   COPY delux.estado (id, disponibilidad) FROM stdin;
    delux          postgres    false    212       2973.dat �          0    50764    notificacion_de_servicio 
   TABLE DATA             COPY delux.notificacion_de_servicio (id_cliente, id, id_destino, id_ubicacion, descripcion_servicio, tarifa, fecha_carrera, pago, kilometros, estado, conductor, comentario_de_conductor, fecha_fin_carrera, comentario_de_cliente, id_conductor, conversacion) FROM stdin;
    delux          postgres    false    214       2975.dat �          0    50775    pago 
   TABLE DATA           .   COPY delux.pago (id, descripcion) FROM stdin;
    delux          postgres    false    217       2978.dat �          0    50783    acceso_cliente 
   TABLE DATA           f   COPY seguridad.acceso_cliente (id, id_cliente, ip, mac, fecha_inicio, session, fecha_fin) FROM stdin;
 	   seguridad          postgres    false    219       2980.dat �          0    50791    acceso_conductor 
   TABLE DATA           j   COPY seguridad.acceso_conductor (id, id_conductor, ip, mac, fecha_inicio, session, fecha_fin) FROM stdin;
 	   seguridad          postgres    false    221       2982.dat �          0    50799    auditoriacl 
   TABLE DATA           f   COPY seguridad.auditoriacl (id, fecha, accion, schema, tabla, session, user_bd, data, pk) FROM stdin;
 	   seguridad          postgres    false    223       2984.dat �          0    50807    auditoriaco 
   TABLE DATA           f   COPY seguridad.auditoriaco (id, fecha, accion, schema, tabla, session, user_bd, data, pk) FROM stdin;
 	   seguridad          postgres    false    225       2986.dat �          0    50820    token_recuperacion 
   TABLE DATA           X   COPY seguridad.token_recuperacion (id, id_cliente, token, creado, vigencia) FROM stdin;
 	   seguridad          postgres    false    228       2988.dat �          0    50826    token_recuperacion_conductor 
   TABLE DATA           d   COPY seguridad.token_recuperacion_conductor (id, id_conductor, token, creado, vigencia) FROM stdin;
 	   seguridad          postgres    false    229       2989.dat �           0    0    administrador_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('delux.administrador_id_seq', 2, true);
          delux          postgres    false    207         �           0    0    cliente_id_cliente_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('delux.cliente_id_cliente_seq', 13, true);
          delux          postgres    false    208         �           0    0    conductor_id_conductor_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('delux.conductor_id_conductor_seq', 9, true);
          delux          postgres    false    209         �           0    0    destino_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('delux.destino_id_seq', 10, true);
          delux          postgres    false    211         �           0    0    estado_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('delux.estado_id_seq', 3, true);
          delux          postgres    false    213         �           0    0 '   notificacion de servicio_id_cliente_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('delux."notificacion de servicio_id_cliente_seq"', 1, false);
          delux          postgres    false    215         �           0    0    notificacion de servicio_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('delux."notificacion de servicio_id_seq"', 38, true);
          delux          postgres    false    216         �           0    0    pago_id_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('delux.pago_id_seq', 5, true);
          delux          postgres    false    218         �           0    0    acceso_cliente_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('seguridad.acceso_cliente_id_seq', 384, true);
       	   seguridad          postgres    false    220         �           0    0    acceso_conductor_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('seguridad.acceso_conductor_id_seq', 640, true);
       	   seguridad          postgres    false    222         �           0    0    auditoriacl_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('seguridad.auditoriacl_id_seq', 47, true);
       	   seguridad          postgres    false    224         �           0    0    auditoriaco_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('seguridad.auditoriaco_id_seq', 108, true);
       	   seguridad          postgres    false    226         �           0    0 #   token_recuperacion_conductor_id_seq    SEQUENCE SET     T   SELECT pg_catalog.setval('seguridad.token_recuperacion_conductor_id_seq', 9, true);
       	   seguridad          postgres    false    230         �           0    0    token_recuperacion_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('seguridad.token_recuperacion_id_seq', 16, true);
       	   seguridad          postgres    false    231         �
           2606    50851     administrador administrador_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY delux.administrador
    ADD CONSTRAINT administrador_pkey PRIMARY KEY (id);
 I   ALTER TABLE ONLY delux.administrador DROP CONSTRAINT administrador_pkey;
       delux            postgres    false    206         �
           2606    50853    cliente cliente_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY delux.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);
 =   ALTER TABLE ONLY delux.cliente DROP CONSTRAINT cliente_pkey;
       delux            postgres    false    204         �
           2606    50855    conductor conductor_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY delux.conductor
    ADD CONSTRAINT conductor_pkey PRIMARY KEY (id_conductor);
 A   ALTER TABLE ONLY delux.conductor DROP CONSTRAINT conductor_pkey;
       delux            postgres    false    205         �
           2606    50857    destino destino_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY delux.destino
    ADD CONSTRAINT destino_pkey PRIMARY KEY (id);
 =   ALTER TABLE ONLY delux.destino DROP CONSTRAINT destino_pkey;
       delux            postgres    false    210                     2606    50859 6   notificacion_de_servicio notificacion de servicio_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY delux.notificacion_de_servicio
    ADD CONSTRAINT "notificacion de servicio_pkey" PRIMARY KEY (id);
 a   ALTER TABLE ONLY delux.notificacion_de_servicio DROP CONSTRAINT "notificacion de servicio_pkey";
       delux            postgres    false    214                    2606    50861    pago pago_pkey 
   CONSTRAINT     K   ALTER TABLE ONLY delux.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id);
 7   ALTER TABLE ONLY delux.pago DROP CONSTRAINT pago_pkey;
       delux            postgres    false    217         �
           2606    50863    estado pk_delux_estado 
   CONSTRAINT     S   ALTER TABLE ONLY delux.estado
    ADD CONSTRAINT pk_delux_estado PRIMARY KEY (id);
 ?   ALTER TABLE ONLY delux.estado DROP CONSTRAINT pk_delux_estado;
       delux            postgres    false    212                    2606    50865 "   acceso_cliente acceso_cliente_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY seguridad.acceso_cliente
    ADD CONSTRAINT acceso_cliente_pkey PRIMARY KEY (id);
 O   ALTER TABLE ONLY seguridad.acceso_cliente DROP CONSTRAINT acceso_cliente_pkey;
    	   seguridad            postgres    false    219                    2606    50867 &   acceso_conductor acceso_conductor_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY seguridad.acceso_conductor
    ADD CONSTRAINT acceso_conductor_pkey PRIMARY KEY (id);
 S   ALTER TABLE ONLY seguridad.acceso_conductor DROP CONSTRAINT acceso_conductor_pkey;
    	   seguridad            postgres    false    221                    2606    50869 "   auditoriacl pk_seguridad_auditoria 
   CONSTRAINT     c   ALTER TABLE ONLY seguridad.auditoriacl
    ADD CONSTRAINT pk_seguridad_auditoria PRIMARY KEY (id);
 O   ALTER TABLE ONLY seguridad.auditoriacl DROP CONSTRAINT pk_seguridad_auditoria;
    	   seguridad            postgres    false    223         
           2606    50871 $   auditoriaco pk_seguridad_auditoriaco 
   CONSTRAINT     e   ALTER TABLE ONLY seguridad.auditoriaco
    ADD CONSTRAINT pk_seguridad_auditoriaco PRIMARY KEY (id);
 Q   ALTER TABLE ONLY seguridad.auditoriaco DROP CONSTRAINT pk_seguridad_auditoriaco;
    	   seguridad            postgres    false    225                    2606    50873 >   token_recuperacion_conductor token_recuperacion_conductor_pkey 
   CONSTRAINT        ALTER TABLE ONLY seguridad.token_recuperacion_conductor
    ADD CONSTRAINT token_recuperacion_conductor_pkey PRIMARY KEY (id);
 k   ALTER TABLE ONLY seguridad.token_recuperacion_conductor DROP CONSTRAINT token_recuperacion_conductor_pkey;
    	   seguridad            postgres    false    229                    2606    50875 *   token_recuperacion token_recuperacion_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY seguridad.token_recuperacion
    ADD CONSTRAINT token_recuperacion_pkey PRIMARY KEY (id);
 W   ALTER TABLE ONLY seguridad.token_recuperacion DROP CONSTRAINT token_recuperacion_pkey;
    	   seguridad            postgres    false    228         �
           1259    50876    fki_fk_delux_estado    INDEX     M   CREATE INDEX fki_fk_delux_estado ON delux.conductor USING btree (id_estado);
 &   DROP INDEX delux.fki_fk_delux_estado;
       delux            postgres    false    205         �
           1259    50877 &   fki_id_cliente_notificacion_de_cliente    INDEX     p   CREATE INDEX fki_id_cliente_notificacion_de_cliente ON delux.notificacion_de_servicio USING btree (id_cliente);
 9   DROP INDEX delux.fki_id_cliente_notificacion_de_cliente;
       delux            postgres    false    214         �
           1259    50878 )   fki_id_conductor_notificacion_de_servicio    INDEX     u   CREATE INDEX fki_id_conductor_notificacion_de_servicio ON delux.notificacion_de_servicio USING btree (id_conductor);
 <   DROP INDEX delux.fki_id_conductor_notificacion_de_servicio;
       delux            postgres    false    214                    2620    50879    cliente tg_delux_cliente    TRIGGER     �   CREATE TRIGGER tg_delux_cliente AFTER INSERT OR DELETE OR UPDATE ON delux.cliente FOR EACH ROW EXECUTE FUNCTION seguridad.f_log_auditoriacl();
 0   DROP TRIGGER tg_delux_cliente ON delux.cliente;
       delux          postgres    false    204    232                    2620    50880    conductor tg_delux_conductor    TRIGGER     �   CREATE TRIGGER tg_delux_conductor AFTER INSERT OR DELETE OR UPDATE ON delux.conductor FOR EACH ROW EXECUTE FUNCTION seguridad.f_log_auditoriaco();
 4   DROP TRIGGER tg_delux_conductor ON delux.conductor;
       delux          postgres    false    233    205                    2606    50881    conductor fk_delux_estado    FK CONSTRAINT     �   ALTER TABLE ONLY delux.conductor
    ADD CONSTRAINT fk_delux_estado FOREIGN KEY (id_estado) REFERENCES delux.estado(id) NOT VALID;
 B   ALTER TABLE ONLY delux.conductor DROP CONSTRAINT fk_delux_estado;
       delux          postgres    false    2812    212    205                    2606    50886 <   notificacion_de_servicio id_cliente_notificacion_de_servicio    FK CONSTRAINT     �   ALTER TABLE ONLY delux.notificacion_de_servicio
    ADD CONSTRAINT id_cliente_notificacion_de_servicio FOREIGN KEY (id_cliente) REFERENCES delux.cliente(id_cliente) NOT VALID;
 e   ALTER TABLE ONLY delux.notificacion_de_servicio DROP CONSTRAINT id_cliente_notificacion_de_servicio;
       delux          postgres    false    2803    204    214                    2606    50891 >   notificacion_de_servicio id_conductor_notificacion_de_servicio    FK CONSTRAINT     �   ALTER TABLE ONLY delux.notificacion_de_servicio
    ADD CONSTRAINT id_conductor_notificacion_de_servicio FOREIGN KEY (id_conductor) REFERENCES delux.conductor(id_conductor) NOT VALID;
 g   ALTER TABLE ONLY delux.notificacion_de_servicio DROP CONSTRAINT id_conductor_notificacion_de_servicio;
       delux          postgres    false    214    205    2805                    2606    50896    acceso_cliente id_cliente    FK CONSTRAINT     �   ALTER TABLE ONLY seguridad.acceso_cliente
    ADD CONSTRAINT id_cliente FOREIGN KEY (id_cliente) REFERENCES delux.cliente(id_cliente) NOT VALID;
 F   ALTER TABLE ONLY seguridad.acceso_cliente DROP CONSTRAINT id_cliente;
    	   seguridad          postgres    false    219    204    2803                    2606    50901    acceso_conductor id_conductor    FK CONSTRAINT     �   ALTER TABLE ONLY seguridad.acceso_conductor
    ADD CONSTRAINT id_conductor FOREIGN KEY (id_conductor) REFERENCES delux.conductor(id_conductor) NOT VALID;
 J   ALTER TABLE ONLY seguridad.acceso_conductor DROP CONSTRAINT id_conductor;
    	   seguridad          postgres    false    221    205    2805                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          2967.dat                                                                                            0000600 0004000 0002000 00000000065 13761310104 0014256 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	jdalzate	1007303580james
2	palejandra	aleja25
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                           2965.dat                                                                                            0000600 0004000 0002000 00000001355 13761310104 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	James Daniel	Alzate Rios	2001-04-02	james.alzate22@gmail.com	james	0702	sistema	activo	\N
10	Ivan	Preciado	1999-11-09	ivanalexanderpreciado0702@gmail.com	ivan	0702	mototaxideluxe	activo	\N
11	Daniel	Rios	2001-04-02	james.alzate22@gmail.com	daniel	daniel2	mototaxideluxe	activo	\N
12	James	Rios	2001-04-02	james@gmail.com	james444	james1	mototaxideluxe	activo	\N
9	Ana Milena	Rios Gallego	1979-08-07	amirriga@gmail.com	amirriga	anarios123	mototaxideluxe	activo	\N
13	Ana Maria	Alzate Rios	1997-09-05	alzateriosanamaria@gmail.com	anita	1234	mototaxideluxe	activo	\N
4	Luz Mery	Cruz	1972-08-04	luzcruz270@gmail.com	mery	123	sistema	sancionado	\N
2	Paula Alejandra	Guzman Cruz	2001-04-13	paulaguzman270@gmail.com	aleja	0402	sifuncionó	activo	\N
\.


                                                                                                                                                                                                                                                                                   2966.dat                                                                                            0000600 0004000 0002000 00000001544 13761310104 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2	Alejandra	Guzman	2001-04-13	paulaguzman270@gmail.com	MKS016	3213665008	aleja	aleja1	sistema	activo	1	1234567890	\N
4	James Daniel 	Alzate Rios	2001-04-02	james.alzate22@gmail.com	NVT610	3134034672	jamesda	0702	sistema	activo	3	1007303580	\N
6	James Rogelio	Alzate Cardenas	1978-11-26	jamesrogelioa82@gmail.com	NVT610	3229424107	jaroalza1	jamesalzate	motodeluxe	activo	1	1234567890	\N
7	Ivan Alexander	Preciado Horta	1999-11-09	ivanalexanderpreciado0702@gmail.com	JYA702	3108869467	ivan	1234	motodeluxe	activo	1	1070990186	\N
3	Luz Mery	Cruz	1972-08-04	luzcruz270@gmail.com	MK89	3103635583	luz	mery	sistema	sancionado	3	1234567890	\N
9	Juanito	Perez	1980-05-02	james.alzate22@gmail.com	ABD78	3104587945	juanito	juanito123	motodeluxe	activo	3	1005879462	\N
8	Mario	Cruz	2000-08-21	mariocruz@gmail.com	MNJI92	3165678222	mario	2108	motodeluxe	activo	3	107099088	\N
\.


                                                                                                                                                            2971.dat                                                                                            0000600 0004000 0002000 00000000274 13761310104 0014253 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Pilaca	Pilaca\n
2	Limonal	Limonal
3	La granja	La granja
4	Mesetas	Mesetas
5	Santa Ana	Santa Ana
6	La mercedes	La mercedes
8	San bernardo	San bernardo
9	Guane	Guane
10	Centro	Centro
\.


                                                                                                                                                                                                                                                                                                                                    2973.dat                                                                                            0000600 0004000 0002000 00000000056 13761310104 0014253 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Disponible
2	Ocupado
3	Fuera de lineal
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  2975.dat                                                                                            0000600 0004000 0002000 00000003652 13761310104 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2	15	1	10	\N	100	2020-10-28 00:00:00-05	1	5	Aceptado	Ivan Alexander	ok	2020-11-17 10:11:49.311036-05	\N	7	Conductor Ivan Alexander: Ya voy llegando sumerce
2	19	2	3	lo necesito urgente	1860	2020-11-03 00:00:00-05	1	5	Aceptado	Ivan Alexander	ok	2020-11-17 08:18:24.472675-05	\N	7	\N
2	20	2	3	.	1860	2020-11-03 00:00:00-05	1	10	Aceptado	Ivan Alexander	excelente	2020-11-17 10:13:32.737564-05	\N	7	\N
2	21	2	3	ya	1860	2020-11-03 00:00:00-05	2	20	Aceptado	Ivan Alexander	ok	2020-11-17 08:23:50.583057-05	\N	7	\N
2	22	4	9	urgente	7800	2020-11-03 00:00:00-05	3	12	Aceptado	James Daniel 	Muy bien	2020-11-12 15:40:56.487502-05	\N	4	\N
9	26	3	5		6000	2020-11-13 00:00:00-05	1	10	Aceptado	Alejandra	:)	2020-11-13 16:36:25.10284-05	\N	2	\N
1	23	2	4		4140	2020-11-04 00:00:00-05	3	15	Aceptado	Ivan Alexander	ok	2020-11-17 19:17:58.168542-05	ok	7	\N
1	24	1	2	gfdhghfghgfhfghfgh	2580	2020-11-05 00:00:00-05	1	5	Aceptado	Ivan Alexander	ok	2020-11-17 09:22:17.922121-05	ok	7	\N
1	25	2	4		6000	2020-11-08 00:00:00-05	1	10	Aceptado	Ivan Alexander	ok	2020-11-17 09:22:10.247531-05	ok	7	\N
1	31	10	2		6000	2020-11-16 00:00:00-05	1	10	Aceptado	Alejandra	\N	\N	\N	2	\N
1	34	4	5		12000	2020-11-18 00:00:00-05	1	20	Aceptado	Ivan Alexander	\N	\N	\N	7	\N
1	33	2	4		6000	2020-11-18 00:00:00-05	1	10	Aceptado	Ivan Alexander	\N	\N	\N	7	\N
1	36	2	4		3240	2020-11-23 00:00:00-05	2	5.4	Pendiente	\N	\N	\N	\N	\N	\N
1	35	4	5		5040	2020-11-23 00:00:00-05	1	8.4	Aceptado	Ivan Alexander	\N	\N	\N	7	\N
11	27	5	10		60000	2020-11-13 00:00:00-05	2	100	Aceptado	Ivan Alexander	Sin problemas	2020-11-30 15:40:52.146537-05	\N	7	\N
1	18	5	4		5040	2020-10-30 00:00:00-05	1	10	Aceptado	Ivan Alexander	muy bien	2020-11-17 10:12:32.514423-05	muy bien	7	Cliente James Daniel: hola
1	38	3	6		6000	2020-11-30 00:00:00-05	1	10	Aceptado	Ivan Alexander	\N	\N	\N	7	Cliente James Daniel: a que hora viene
1	32	3	4		6000	2020-11-17 00:00:00-05	1	10	Aceptado	Ivan Alexander	ok	2020-11-30 19:15:01.402146-05	ok	7	\N
\.


                                                                                      2978.dat                                                                                            0000600 0004000 0002000 00000000076 13761310104 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	Efectivo\n
2	Tarjeta
3	Daviplata
4	Nequi
5	Movi Cuenta
\.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                  2980.dat                                                                                            0000600 0004000 0002000 00000073342 13761310104 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        2	2	192.168.1.8	68F728DA75A0	2020-10-13 08:42:02.386282	jfnq4piif5gplqxxjm2qei3o	2020-10-14 15:51:35.327716
5	1	192.168.1.8	68F728DA75A0	2020-10-14 15:59:11.462054	jfnq4piif5gplqxxjm2qei3o	2020-10-14 15:59:13.146753
6	4	192.168.1.8	68F728DA75A0	2020-10-14 15:59:51.1494	jfnq4piif5gplqxxjm2qei3o	2020-10-14 16:59:47.68386
22	2	192.168.1.8	68F728DA75A0	2020-10-19 11:59:58.154568	2tqvruax3ajn2yqwxsgnm25m	2020-10-19 12:00:00.923438
7	4	192.168.1.8	68F728DA75A0	2020-10-14 16:05:59.317071	jfnq4piif5gplqxxjm2qei3o	2020-10-19 14:40:33.42118
8	4	192.168.1.8	68F728DA75A0	2020-10-14 16:40:41.339154	jfnq4piif5gplqxxjm2qei3o	2020-10-19 14:49:57.349667
27	1	192.168.0.107	A81E84BE50F1	2020-10-19 14:51:28.581603	33eh0dl4a1fypptm4hgpdh2f	2020-10-19 14:51:32.572045
29	1	192.168.0.107	A81E84BE50F1	2020-10-20 07:29:33.90158	slj5xn5jk03ehrplfswz1cx3	2020-10-21 14:47:02.198866
34	2	192.168.0.107	A81E84BE50F1	2020-10-21 14:48:22.443216	lfgbohuj5hbtpcuigxebe0bc	2020-10-21 14:50:39.27746
35	2	192.168.0.107	A81E84BE50F1	2020-10-21 14:49:54.82644	gcnnsvkmshknblrdwmpnfjdn	2020-10-21 15:02:02.254285
36	2	192.168.0.107	A81E84BE50F1	2020-10-21 14:54:25.951309	1hgfqdge0qtt3giehpf5v2k5	2020-10-21 15:12:02.582769
37	2	192.168.0.107	A81E84BE50F1	2020-10-21 14:55:59.838424	aob0as1zlfp5mzqarz3dxsbz	2020-10-21 15:46:18.47603
38	2	192.168.0.107	A81E84BE50F1	2020-10-21 14:59:06.098802	zpyvesgcu4t3t40xczhj1jnn	2020-10-21 15:47:06.952574
39	2	192.168.0.107	A81E84BE50F1	2020-10-21 15:00:31.96262	usycx5rvuqeyfqh2yvzm4lzp	2020-10-21 15:51:24.827245
30	1	127.0.0.1	A81E84BE50F1	2020-10-20 07:31:54.025895	gdh4om5vocmcz5e1305z0bxu	2020-10-21 16:01:39.801091
31	1	127.0.0.1	A81E84BE50F1	2020-10-20 07:34:15.270055	qsuazx3kw4m0ky3c5bl3gr3z	2020-10-21 16:09:41.450985
28	9	192.168.0.107	A81E84BE50F1	2020-10-19 16:48:49.572276	f5ncr1tauv3ee423vqpmhrkz	2020-10-21 16:19:25.853289
9	4	192.168.1.8	68F728DA75A0	2020-10-14 16:58:24.45583	jfnq4piif5gplqxxjm2qei3o	2020-10-21 16:42:40.600571
10	4	192.168.1.8	68F728DA75A0	2020-10-14 16:59:42.815904	jfnq4piif5gplqxxjm2qei3o	2020-10-21 16:43:26.351879
71	10	192.168.1.8	68F728DA75A0	2020-10-21 16:56:40.871932	mr3rgziz0xx4a31tky14ofzg	2020-10-21 16:56:41.034837
72	2	192.168.1.8	68F728DA75A0	2020-10-21 16:59:29.817253	mr3rgziz0xx4a31tky14ofzg	2020-10-21 16:59:29.944292
73	1	192.168.0.107	A81E84BE50F1	2020-10-21 17:29:55.149119	4e3sk3u2lnybrtiqypo0jdgf	2020-10-21 17:29:55.905278
74	1	192.168.0.107	A81E84BE50F1	2020-10-21 17:34:49.629041	vb4mqapjljmmeh1cnj4trw1f	2020-10-21 17:34:52.411391
75	2	192.168.0.107	A81E84BE50F1	2020-10-21 17:37:45.656636	dx2sjwk3s5vmrxdfs5u4ezus	2020-10-21 17:41:00.933481
77	1	192.168.0.107	A81E84BE50F1	2020-10-22 16:50:53.55202	bpfoux1v2jduf4g055o3x5qf	2020-10-22 16:51:00.838471
78	2	192.168.0.107	A81E84BE50F1	2020-10-22 16:51:31.306689	bpfoux1v2jduf4g055o3x5qf	2020-10-22 16:51:42.186867
79	1	192.168.0.107	A81E84BE50F1	2020-10-22 16:52:12.278439	41laohyhrz31pthj0ox4pqmv	2020-10-22 16:52:14.020614
80	1	192.168.0.107	A81E84BE50F1	2020-10-22 18:14:50.772617	ci2jv4gqepwqlaufalqrftw5	2020-10-22 18:15:11.934514
81	10	192.168.0.107	A81E84BE50F1	2020-10-22 18:16:16.924106	i4sv1j4sddpy41fipuaqp2p5	2020-10-22 18:17:11.357333
82	10	192.168.0.107	A81E84BE50F1	2020-10-22 18:19:47.243224	nhhm3bkv5sn3wvvk1oinissm	2020-10-22 18:19:54.244209
83	10	192.168.0.107	A81E84BE50F1	2020-10-22 18:20:24.132684	2d3darlql50o0ofthqqh0acu	2020-10-22 18:20:30.44124
84	10	192.168.0.107	A81E84BE50F1	2020-10-22 18:20:52.147771	mvxijd5pe4kxovls4lrkkcbf	2020-10-22 18:21:01.774722
85	1	192.168.0.107	A81E84BE50F1	2020-10-22 18:21:22.864101	hzlb1lh3futznmkbdaxh3c23	2020-10-22 18:21:31.388665
86	10	192.168.0.107	A81E84BE50F1	2020-10-22 18:22:00.514691	argavdhk2cpkwwh44l1ow3oe	2020-10-22 18:22:04.953861
87	10	192.168.0.107	A81E84BE50F1	2020-10-22 18:22:29.796572	bdsqtewdnf2lf3xrq2v0dpbt	2020-10-22 18:22:43.181009
88	1	192.168.0.107	A81E84BE50F1	2020-10-22 18:22:48.869491	bdsqtewdnf2lf3xrq2v0dpbt	2020-10-22 18:23:05.234637
89	1	192.168.0.107	A81E84BE50F1	2020-10-23 11:58:34.581137	4hdnod1mpzuoic3jg40g1ajv	2020-10-23 11:58:36.548253
90	1	192.168.0.107	A81E84BE50F1	2020-10-26 11:56:26.212343	f1mjwq4ouck5ygi04axyy3cz	2020-10-26 11:56:30.480415
91	1	192.168.1.8	68F728DA75A0	2020-10-26 12:15:55.256431	bophzahwugdpu35xzcxkoeft	2020-10-26 12:16:04.33798
96	2	192.168.1.8	68F728DA75A0	2020-10-26 20:31:12.059284	bophzahwugdpu35xzcxkoeft	2020-10-26 20:37:23.550768
97	2	192.168.1.8	68F728DA75A0	2020-10-26 20:32:48.615536	bophzahwugdpu35xzcxkoeft	2020-10-27 15:40:18.686268
98	2	192.168.1.8	68F728DA75A0	2020-10-26 20:33:31.026611	bophzahwugdpu35xzcxkoeft	2020-10-27 15:55:24.867019
99	2	192.168.1.8	68F728DA75A0	2020-10-26 20:35:50.632561	bophzahwugdpu35xzcxkoeft	2020-10-27 16:17:14.526297
100	2	192.168.1.8	68F728DA75A0	2020-10-26 20:37:21.330511	bophzahwugdpu35xzcxkoeft	2020-10-27 17:17:44.432935
101	2	192.168.1.8	68F728DA75A0	2020-10-26 20:37:30.374504	bophzahwugdpu35xzcxkoeft	2020-10-27 17:22:18.901364
102	2	192.168.1.8	68F728DA75A0	2020-10-26 20:39:15.59493	bophzahwugdpu35xzcxkoeft	2020-10-28 11:12:54.785655
103	2	192.168.1.8	68F728DA75A0	2020-10-26 20:46:00.863873	bophzahwugdpu35xzcxkoeft	2020-10-28 11:18:26.225938
104	2	192.168.1.8	68F728DA75A0	2020-10-26 20:46:33.719881	bophzahwugdpu35xzcxkoeft	2020-10-28 11:25:23.126204
105	2	192.168.1.8	68F728DA75A0	2020-10-27 15:33:43.704295	bophzahwugdpu35xzcxkoeft	2020-10-28 11:26:34.055597
118	1	192.168.1.8	68F728DA75A0	2020-10-28 11:27:34.813896	bophzahwugdpu35xzcxkoeft	2020-10-28 11:28:32.116528
106	2	192.168.1.8	68F728DA75A0	2020-10-27 15:40:07.302665	bophzahwugdpu35xzcxkoeft	2020-10-28 12:28:09.744771
107	2	192.168.1.8	68F728DA75A0	2020-10-27 15:45:40.39062	bophzahwugdpu35xzcxkoeft	2020-10-28 15:11:02.996178
108	2	192.168.1.8	68F728DA75A0	2020-10-27 15:53:20.125361	bophzahwugdpu35xzcxkoeft	2020-10-28 16:18:12.970153
109	2	192.168.1.8	68F728DA75A0	2020-10-27 15:54:46.628037	bophzahwugdpu35xzcxkoeft	2020-10-28 16:25:04.584175
111	2	192.168.1.8	68F728DA75A0	2020-10-27 17:17:05.507847	bophzahwugdpu35xzcxkoeft	2020-10-28 16:29:47.297829
112	2	192.168.1.8	68F728DA75A0	2020-10-27 17:21:49.358809	bophzahwugdpu35xzcxkoeft	2020-10-28 16:45:21.008858
113	2	192.168.1.8	68F728DA75A0	2020-10-28 11:12:42.656003	bophzahwugdpu35xzcxkoeft	2020-10-28 17:35:45.939615
115	2	192.168.1.8	68F728DA75A0	2020-10-28 11:17:05.491591	bophzahwugdpu35xzcxkoeft	2020-10-28 17:46:05.569757
116	2	192.168.1.8	68F728DA75A0	2020-10-28 11:24:15.194225	bophzahwugdpu35xzcxkoeft	2020-10-28 17:47:47.539409
119	1	192.168.1.8	68F728DA75A0	2020-10-28 11:30:07.458751	bophzahwugdpu35xzcxkoeft	2020-10-28 11:30:28.560995
120	1	192.168.1.8	68F728DA75A0	2020-10-28 11:31:50.334528	bophzahwugdpu35xzcxkoeft	2020-10-28 11:32:08.674579
121	1	192.168.1.8	68F728DA75A0	2020-10-28 11:45:02.399748	bophzahwugdpu35xzcxkoeft	2020-10-28 11:50:25.247315
122	1	192.168.1.8	68F728DA75A0	2020-10-28 11:45:50.291354	bophzahwugdpu35xzcxkoeft	2020-10-28 11:51:51.096509
123	1	192.168.1.8	68F728DA75A0	2020-10-28 11:46:35.65567	bophzahwugdpu35xzcxkoeft	2020-10-28 11:53:32.154334
124	1	192.168.1.8	68F728DA75A0	2020-10-28 11:47:15.341238	bophzahwugdpu35xzcxkoeft	2020-10-28 12:04:35.410582
125	1	192.168.1.8	68F728DA75A0	2020-10-28 11:48:12.787221	bophzahwugdpu35xzcxkoeft	2020-10-28 12:09:23.890034
126	1	192.168.1.8	68F728DA75A0	2020-10-28 11:51:29.018012	bophzahwugdpu35xzcxkoeft	2020-10-28 12:11:21.770886
127	1	192.168.1.8	68F728DA75A0	2020-10-28 11:53:10.922592	bophzahwugdpu35xzcxkoeft	2020-10-28 12:25:12.453866
128	1	192.168.1.8	68F728DA75A0	2020-10-28 12:04:15.802858	bophzahwugdpu35xzcxkoeft	2020-10-28 12:26:15.370666
129	1	192.168.1.8	68F728DA75A0	2020-10-28 12:08:45.297951	bophzahwugdpu35xzcxkoeft	2020-10-28 16:21:41.59407
130	1	192.168.1.8	68F728DA75A0	2020-10-28 12:10:57.067609	bophzahwugdpu35xzcxkoeft	2020-10-28 16:23:53.835663
110	2	192.168.1.8	68F728DA75A0	2020-10-27 16:16:00.292596	bophzahwugdpu35xzcxkoeft	2020-10-28 16:28:55.062947
131	1	192.168.1.8	68F728DA75A0	2020-10-28 12:24:49.684683	bophzahwugdpu35xzcxkoeft	2020-10-28 17:17:09.009694
132	1	192.168.1.8	68F728DA75A0	2020-10-28 12:25:49.686866	bophzahwugdpu35xzcxkoeft	2020-10-28 17:22:50.826252
135	1	192.168.1.8	68F728DA75A0	2020-10-28 15:54:09.678029	bophzahwugdpu35xzcxkoeft	2020-10-28 17:24:37.631033
137	1	192.168.1.8	68F728DA75A0	2020-10-28 16:21:34.14411	bophzahwugdpu35xzcxkoeft	2020-10-28 17:30:44.726916
138	1	192.168.1.8	68F728DA75A0	2020-10-28 16:23:13.217989	bophzahwugdpu35xzcxkoeft	2020-10-28 17:34:30.106498
114	2	192.168.1.8	68F728DA75A0	2020-10-28 11:15:57.91197	bophzahwugdpu35xzcxkoeft	2020-10-28 17:36:50.671895
144	1	192.168.1.8	68F728DA75A0	2020-10-28 17:16:59.915844	bophzahwugdpu35xzcxkoeft	2020-10-28 17:44:38.473128
145	1	192.168.1.8	68F728DA75A0	2020-10-28 17:22:17.197397	bophzahwugdpu35xzcxkoeft	2020-10-28 18:59:29.392224
146	1	192.168.1.8	68F728DA75A0	2020-10-28 17:24:26.596228	bophzahwugdpu35xzcxkoeft	2020-10-29 17:34:59.788905
147	1	192.168.1.8	68F728DA75A0	2020-10-28 17:30:19.297029	bophzahwugdpu35xzcxkoeft	2020-10-29 17:38:42.507428
148	1	192.168.1.8	68F728DA75A0	2020-10-28 17:34:21.117334	bophzahwugdpu35xzcxkoeft	2020-10-29 17:40:35.052496
151	1	192.168.1.8	68F728DA75A0	2020-10-28 17:44:30.353784	bophzahwugdpu35xzcxkoeft	2020-10-29 17:49:44.580919
154	1	192.168.0.107	A81E84BE50F1	2020-10-28 18:53:58.748136	gyce0jpk2tywqfrn5slqv5hn	2020-10-29 17:54:27.236788
155	1	192.168.0.107	A81E84BE50F1	2020-10-28 18:56:20.994101	5on1cpsxyrp4ugckhio3v550	2020-10-29 17:58:55.859478
156	1	127.0.0.1	A81E84BE50F1	2020-10-29 17:34:32.640194	k1ygzf14nz10m0ijhhv4cztv	2020-10-29 18:00:09.048834
157	1	127.0.0.1	A81E84BE50F1	2020-10-29 17:38:24.775221	vrn1holav43hzyphkanegu0q	2020-10-29 20:02:14.458031
158	1	127.0.0.1	A81E84BE50F1	2020-10-29 17:40:15.587562	n0jylnuwpulfuq5rkgzagfdd	2020-10-29 20:09:48.671658
159	1	127.0.0.1	A81E84BE50F1	2020-10-29 17:49:29.231247	v0xs4rjbtubrxp3mf3zzar4y	2020-10-29 20:35:44.562756
160	1	127.0.0.1	A81E84BE50F1	2020-10-29 17:53:26.860446	beymw5f0myukdkgbiodlwcgm	2020-10-29 20:37:17.170747
161	1	127.0.0.1	A81E84BE50F1	2020-10-29 17:58:20.380425	rbj3pdrddjrxee2gunvbatnt	2020-10-29 20:51:09.354602
162	1	127.0.0.1	A81E84BE50F1	2020-10-29 17:59:52.654283	j4gv2m3sf4ljsyf2ju054nid	2020-10-29 21:08:37.422357
163	1	192.168.0.107	A81E84BE50F1	2020-10-29 20:01:38.808991	2pwkikophiwzlvv0yfsq41vf	2020-10-29 21:27:13.31516
117	2	192.168.1.8	68F728DA75A0	2020-10-28 11:26:14.222539	bophzahwugdpu35xzcxkoeft	2020-10-30 17:02:38.163786
133	2	192.168.1.8	68F728DA75A0	2020-10-28 12:27:25.077588	bophzahwugdpu35xzcxkoeft	2020-11-03 19:40:49.557246
134	2	192.168.1.8	68F728DA75A0	2020-10-28 15:10:48.614829	bophzahwugdpu35xzcxkoeft	2020-11-03 19:43:27.390424
136	2	192.168.1.8	68F728DA75A0	2020-10-28 16:18:03.499839	bophzahwugdpu35xzcxkoeft	2020-11-03 20:36:46.140717
139	2	192.168.1.8	68F728DA75A0	2020-10-28 16:24:54.519632	bophzahwugdpu35xzcxkoeft	2020-11-03 20:45:56.864289
185	1	192.168.0.107	A81E84BE50F1	2020-11-04 17:30:56.999145	vqzvf0oidlphveujgwkfmnxb	2020-11-04 17:31:22.791545
186	1	192.168.0.107	A81E84BE50F1	2020-11-04 17:46:44.972847	vqzvf0oidlphveujgwkfmnxb	2020-11-04 17:47:00.221389
187	1	192.168.0.107	A81E84BE50F1	2020-11-04 17:49:49.410791	vqzvf0oidlphveujgwkfmnxb	2020-11-04 17:50:25.189401
188	1	192.168.0.107	A81E84BE50F1	2020-11-04 17:51:15.013441	vqzvf0oidlphveujgwkfmnxb	2020-11-04 17:51:59.260372
189	1	192.168.0.107	A81E84BE50F1	2020-11-04 19:07:25.842265	vqzvf0oidlphveujgwkfmnxb	2020-11-04 19:07:40.195908
190	1	192.168.0.107	A81E84BE50F1	2020-11-04 19:13:11.625106	vqzvf0oidlphveujgwkfmnxb	2020-11-04 19:13:52.47
191	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:25:10.7236	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:26:11.725564
192	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:25:40.609868	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:27:25.996025
193	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:27:11.632643	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:30:20.836268
194	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:29:53.952787	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:32:02.370896
195	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:31:50.491751	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:35:48.511796
196	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:35:34.205322	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:36:16.028061
197	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:36:08.305633	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:37:16.725943
198	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:36:35.31068	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:37:54.013257
199	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:37:06.261501	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:39:57.036466
200	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:37:41.699478	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:41:23.290238
201	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:39:27.775017	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:42:56.655738
202	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:40:47.94211	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:44:20.3937
203	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:42:40.753918	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:45:31.032541
204	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:43:57.01174	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:48:00.344581
205	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:45:19.731288	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:50:02.534124
206	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:47:39.291536	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:50:39.529429
207	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:49:42.861689	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:51:28.431789
208	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:50:33.114416	vqzvf0oidlphveujgwkfmnxb	2020-11-08 14:37:27.115264
209	1	192.168.0.107	A81E84BE50F1	2020-11-04 20:51:15.285457	vqzvf0oidlphveujgwkfmnxb	2020-11-08 14:39:42.868805
210	1	192.168.0.107	A81E84BE50F1	2020-11-05 18:55:31.607232	zlbciamz23smjmjv4ewinssi	2020-11-08 14:44:36.150931
211	1	192.168.0.107	A81E84BE50F1	2020-11-08 14:35:52.318945	z5q33iw44mwsfcvnk0dyfrxt	2020-11-08 14:47:49.247693
212	1	192.168.0.107	A81E84BE50F1	2020-11-08 14:39:32.907556	bwjavm3ypi5lsi4pofuwjqsq	2020-11-09 20:18:45.626341
213	1	192.168.0.107	A81E84BE50F1	2020-11-08 14:44:17.992504	0obrescmnmf4gjfb5ryyidsz	2020-11-09 20:22:22.295569
214	1	192.168.0.107	A81E84BE50F1	2020-11-08 14:47:33.186246	i4yyjuvpl1ck45cw252cjmej	2020-11-09 20:25:44.699116
215	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:17:41.507377	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:27:09.35867
216	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:18:24.498381	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:29:44.042539
217	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:21:10.039328	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:31:41.430938
218	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:25:29.932385	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:33:22.135502
219	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:26:57.630502	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:34:12.398786
220	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:29:01.354756	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:38:44.793768
221	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:30:54.8127	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:47:29.238478
222	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:33:08.276071	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:50:06.718508
223	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:33:52.44944	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:51:30.452989
224	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:38:31.340069	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:55:00.585146
225	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:46:27.930213	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:57:31.067305
226	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:49:45.638228	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:59:14.617221
227	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:51:13.949685	gwrc0kszuybbpdyz0avwwyti	2020-11-10 17:51:51.044892
228	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:53:09.385111	gwrc0kszuybbpdyz0avwwyti	2020-11-12 15:41:28.685208
229	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:57:15.260169	gwrc0kszuybbpdyz0avwwyti	2020-11-12 16:15:03.034378
230	1	192.168.0.107	A81E84BE50F1	2020-11-09 20:58:58.156422	gwrc0kszuybbpdyz0avwwyti	2020-11-12 16:20:41.074448
231	1	192.168.0.107	A81E84BE50F1	2020-11-09 21:11:53.110463	gwrc0kszuybbpdyz0avwwyti	2020-11-12 16:21:36.53615
232	1	192.168.0.107	A81E84BE50F1	2020-11-10 17:17:59.397259	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 16:22:38.791175
233	1	192.168.0.107	A81E84BE50F1	2020-11-10 17:18:52.369311	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-13 16:02:37.41305
234	1	192.168.0.107	A81E84BE50F1	2020-11-10 17:48:35.728432	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-13 16:15:12.64527
243	9	192.168.0.107	A81E84BE50F1	2020-11-13 16:15:32.47181	vczwrmwsfmhi0bj5r13hbo2g	2020-11-13 16:17:03.367525
235	1	192.168.0.107	A81E84BE50F1	2020-11-10 17:50:29.673499	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-13 16:17:10.805314
237	1	192.168.0.107	A81E84BE50F1	2020-11-12 16:14:25.555536	vqmbu4wmd11bavolq0whgd0f	2020-11-16 22:51:14.535122
238	1	192.168.0.107	A81E84BE50F1	2020-11-12 16:20:19.300975	vqmbu4wmd11bavolq0whgd0f	2020-11-16 22:58:14.380709
239	1	192.168.0.107	A81E84BE50F1	2020-11-12 16:21:02.78189	vqmbu4wmd11bavolq0whgd0f	2020-11-16 23:18:30.023986
240	1	192.168.0.107	A81E84BE50F1	2020-11-12 16:22:24.884299	vqmbu4wmd11bavolq0whgd0f	2020-11-17 18:40:03.814885
242	1	192.168.0.107	A81E84BE50F1	2020-11-13 16:15:06.021539	vczwrmwsfmhi0bj5r13hbo2g	2020-11-17 20:18:14.012178
247	11	192.168.0.107	A81E84BE50F1	2020-11-13 16:35:22.281674	ni3q5zp20yp0km2hotoni4kz	2020-11-13 16:35:40.321396
236	1	192.168.0.107	A81E84BE50F1	2020-11-12 15:41:21.934553	vqmbu4wmd11bavolq0whgd0f	2020-11-16 21:01:03.956768
241	1	192.168.0.107	A81E84BE50F1	2020-11-13 16:02:21.370217	1b3sed1ji5ron2ru2motbbnv	2020-11-17 20:05:33.294858
246	1	192.168.0.107	A81E84BE50F1	2020-11-13 16:17:07.127874	vczwrmwsfmhi0bj5r13hbo2g	2020-11-17 20:23:39.457346
248	1	192.168.0.107	A81E84BE50F1	2020-11-16 19:01:19.284964	1oaov1x3ifh5mmujd0eckhei	2020-11-17 20:25:05.695983
249	1	192.168.0.107	A81E84BE50F1	2020-11-16 19:02:57.311393	cuqhzdxxrzeo44bqepexusea	2020-11-17 20:37:10.031625
250	1	192.168.0.107	A81E84BE50F1	2020-11-16 19:17:35.035049	qes353uaru254ysfyk5jds5i	2020-11-17 20:39:20.304731
251	1	192.168.0.107	A81E84BE50F1	2020-11-16 21:00:46.700914	o0eyt5342tksmzdsnzwrb3zn	2020-11-17 20:58:46.507406
252	1	192.168.0.107	A81E84BE50F1	2020-11-16 22:47:02.298008	3ebbugb2lsiaho3w1gmsnycv	2020-11-17 20:59:36.450106
253	1	192.168.0.107	A81E84BE50F1	2020-11-16 22:48:46.510045	e1vwf2krpitrbsho3zrfe5w4	2020-11-18 20:04:46.036893
254	1	192.168.0.107	A81E84BE50F1	2020-11-16 22:55:18.189766	e1vwf2krpitrbsho3zrfe5w4	2020-11-18 21:58:39.1784
255	1	192.168.0.107	A81E84BE50F1	2020-11-16 23:18:22.85918	rjk4sjr55b2bmdvl1z1taoiw	2020-11-18 21:59:52.917039
256	1	192.168.0.107	A81E84BE50F1	2020-11-17 18:38:56.862471	2ikmqvsolim3fgofadeznnee	2020-11-18 22:00:36.224033
257	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:04:32.286186	2ikmqvsolim3fgofadeznnee	2020-11-18 22:04:12.036361
258	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:17:51.486592	2ikmqvsolim3fgofadeznnee	2020-11-18 22:19:09.554156
259	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:23:12.081086	2ikmqvsolim3fgofadeznnee	2020-11-18 23:04:32.609596
260	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:24:07.188736	2ikmqvsolim3fgofadeznnee	2020-11-18 23:08:28.115399
261	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:34:42.993065	2ikmqvsolim3fgofadeznnee	2020-11-18 23:11:40.443039
262	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:38:31.316907	2ikmqvsolim3fgofadeznnee	2020-11-18 23:12:38.910885
263	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:58:33.916161	rbpq0z4cwp1diohcvpd3wj0r	2020-11-18 23:14:50.24336
264	1	192.168.0.107	A81E84BE50F1	2020-11-17 20:59:18.448399	rbpq0z4cwp1diohcvpd3wj0r	2020-11-18 23:17:31.713116
265	1	192.168.0.107	A81E84BE50F1	2020-11-18 20:04:38.836798	ffktxs5g3dckduk3vblneqlt	2020-11-18 23:23:07.286312
266	1	192.168.0.107	A81E84BE50F1	2020-11-18 20:04:52.181049	ffktxs5g3dckduk3vblneqlt	2020-11-18 23:25:42.089447
267	1	192.168.0.107	A81E84BE50F1	2020-11-18 21:58:06.51201	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:30:53.70115
268	1	192.168.0.107	A81E84BE50F1	2020-11-18 21:59:39.606702	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:33:03.679138
269	1	192.168.0.107	A81E84BE50F1	2020-11-18 22:00:07.035449	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:34:57.830992
270	1	192.168.0.107	A81E84BE50F1	2020-11-18 22:03:48.844876	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:35:48.480366
271	1	192.168.0.107	A81E84BE50F1	2020-11-18 22:18:37.093382	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:37:37.923091
272	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:02:52.746958	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:45:29.251813
273	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:06:57.366583	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:47:03.862201
274	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:09:41.188381	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:50:27.120698
275	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:12:18.679716	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:53:40.899173
276	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:14:19.467224	hgvtlb3jkoaqeg4xpwclo40m	2020-11-18 23:55:19.688546
277	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:16:17.42959	hgvtlb3jkoaqeg4xpwclo40m	2020-11-19 00:04:55.155228
278	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:18:51.098753	hgvtlb3jkoaqeg4xpwclo40m	2020-11-19 13:26:02.995837
292	2	192.168.0.107	A81E84BE50F1	2020-11-19 13:31:50.885725	54yym3bgwokotf322xejtotd	2020-11-19 13:32:37.038344
293	10	192.168.0.107	A81E84BE50F1	2020-11-19 13:32:45.985658	54yym3bgwokotf322xejtotd	2020-11-19 13:33:07.255909
294	10	192.168.0.107	A81E84BE50F1	2020-11-19 13:33:58.678944	2zk0htuvootvarq0344pv2ix	2020-11-19 13:34:12.358631
295	10	192.168.0.107	A81E84BE50F1	2020-11-19 13:37:33.404833	2qkpaqynkba2p2yflnzcdsw2	2020-11-19 13:38:03.347406
296	10	192.168.0.107	A81E84BE50F1	2020-11-19 13:38:59.081244	verypdeqtkj3gykuo3vm1ipn	2020-11-19 13:39:27.268024
297	10	192.168.0.107	A81E84BE50F1	2020-11-19 13:40:42.603297	twpwchecdtb4rxafibfo2uov	2020-11-19 13:41:01.259485
298	10	192.168.0.107	A81E84BE50F1	2020-11-19 13:41:52.91807	us51eabvydnrzoxy1kl11k0j	2020-11-19 13:42:14.898614
299	2	192.168.0.107	A81E84BE50F1	2020-11-19 13:42:21.124825	us51eabvydnrzoxy1kl11k0j	2020-11-19 13:42:56.195717
279	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:25:17.8707	hgvtlb3jkoaqeg4xpwclo40m	2020-11-19 13:45:58.799313
280	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:30:22.661265	hgvtlb3jkoaqeg4xpwclo40m	2020-11-19 14:52:36.365086
281	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:32:46.227028	hgvtlb3jkoaqeg4xpwclo40m	2020-11-19 15:03:14.397442
282	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:34:05.185802	hgvtlb3jkoaqeg4xpwclo40m	2020-11-19 15:19:54.893087
304	10	192.168.0.107	A81E84BE50F1	2020-11-19 15:19:58.84773	qyihtwtar3fnpnpuf0bxezp5	2020-11-19 15:20:07.414041
283	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:35:41.465788	hgvtlb3jkoaqeg4xpwclo40m	2020-11-19 17:04:53.156665
285	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:44:49.939436	n04fv0r3hzdt2sdojbofncid	2020-11-19 17:27:29.940451
286	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:46:13.422125	n04fv0r3hzdt2sdojbofncid	2020-11-20 11:49:44.314229
287	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:48:50.027277	gcb4xwjoewhk4sxflid2fuit	2020-11-20 14:01:33.639284
289	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:54:15.147164	5kc3od4faute2dcqenrrn134	2020-11-20 14:12:53.680413
290	1	192.168.0.107	A81E84BE50F1	2020-11-19 00:03:54.850465	coorpmxettrx5pe4lia3yvct	2020-11-20 14:13:44.212007
291	1	192.168.0.107	A81E84BE50F1	2020-11-19 13:24:15.535766	zctdj4gecvwxatt0x3gmtjup	2020-11-20 14:14:42.624285
300	1	192.168.0.107	A81E84BE50F1	2020-11-19 13:45:32.895754	any30dgzd4ojgkhtyhvxekwq	2020-11-20 14:14:51.910608
302	1	192.168.0.107	A81E84BE50F1	2020-11-19 15:02:46.514487	obsdywzg1redbtuizxvh33um	2020-11-20 14:31:56.77668
303	1	192.168.0.107	A81E84BE50F1	2020-11-19 15:18:11.289437	qyihtwtar3fnpnpuf0bxezp5	2020-11-20 14:36:24.467417
305	1	192.168.0.107	A81E84BE50F1	2020-11-19 17:04:24.29437	yofmjr0vnevamozzomrdbkji	2020-11-20 14:46:17.62621
284	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:36:40.331215	n04fv0r3hzdt2sdojbofncid	2020-11-19 17:07:42.930966
288	1	192.168.0.107	A81E84BE50F1	2020-11-18 23:53:07.566368	igw2oa2sho4szgv2gajgty5j	2020-11-20 14:08:29.950584
301	1	192.168.0.107	A81E84BE50F1	2020-11-19 14:52:05.426996	gwl5axfes0uu1v0qye02dtxm	2020-11-20 14:30:51.197901
306	1	192.168.0.107	A81E84BE50F1	2020-11-19 17:07:09.414223	zlzxxr31s4enphabz5fy5zea	2020-11-20 21:49:06.085144
307	1	192.168.0.107	A81E84BE50F1	2020-11-19 17:27:10.454522	wmvbw553seng1behofgysrrj	2020-11-20 21:50:16.398848
308	1	192.168.0.107	A81E84BE50F1	2020-11-20 11:49:15.375755	35csithozehd4ntyvwlyjona	2020-11-20 22:01:34.80628
309	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:01:19.796934	35csithozehd4ntyvwlyjona	2020-11-20 22:02:38.014754
310	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:07:47.840849	35csithozehd4ntyvwlyjona	2020-11-20 22:06:22.186157
311	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:12:37.445636	35csithozehd4ntyvwlyjona	2020-11-20 22:07:50.873725
312	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:13:32.290716	35csithozehd4ntyvwlyjona	2020-11-20 22:13:43.292769
326	10	192.168.0.107	A81E84BE50F1	2020-11-20 22:26:13.516679	5ptbe0rmoy1hzucnlaxsstwh	2020-11-20 22:26:32.957709
313	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:14:20.780825	35csithozehd4ntyvwlyjona	2020-11-20 22:29:21.973952
314	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:14:46.981714	35csithozehd4ntyvwlyjona	2020-11-20 22:43:27.478663
315	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:30:32.967164	35csithozehd4ntyvwlyjona	2020-11-20 23:10:29.666538
316	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:31:31.399672	35csithozehd4ntyvwlyjona	2020-11-20 23:12:15.283033
317	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:36:11.768158	35csithozehd4ntyvwlyjona	2020-11-20 23:15:45.057499
318	1	192.168.0.107	A81E84BE50F1	2020-11-20 14:45:38.862129	35csithozehd4ntyvwlyjona	2020-11-20 23:17:06.763575
319	1	192.168.0.107	A81E84BE50F1	2020-11-20 21:48:13.112494	5ptbe0rmoy1hzucnlaxsstwh	2020-11-20 23:20:03.256618
320	1	192.168.0.107	A81E84BE50F1	2020-11-20 21:49:45.403376	5ptbe0rmoy1hzucnlaxsstwh	2020-11-20 23:27:08.797405
321	1	192.168.0.107	A81E84BE50F1	2020-11-20 22:00:51.423218	5ptbe0rmoy1hzucnlaxsstwh	2020-11-20 23:29:00.509206
322	1	192.168.0.107	A81E84BE50F1	2020-11-20 22:02:22.413299	5ptbe0rmoy1hzucnlaxsstwh	2020-11-22 10:09:38.379204
323	1	192.168.0.107	A81E84BE50F1	2020-11-20 22:05:47.230115	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 13:48:43.983049
324	1	192.168.0.107	A81E84BE50F1	2020-11-20 22:07:32.697049	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 16:27:38.803925
325	1	192.168.0.107	A81E84BE50F1	2020-11-20 22:13:21.542435	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 16:29:35.55727
327	1	192.168.0.107	A81E84BE50F1	2020-11-20 22:28:33.136767	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 17:02:39.445718
328	1	192.168.0.107	A81E84BE50F1	2020-11-20 22:42:57.96988	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 17:04:47.222976
329	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:09:45.454722	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 17:08:27.342205
330	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:11:27.41956	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 22:00:20.114221
331	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:12:47.626644	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 22:04:57.787804
332	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:14:35.594366	5ptbe0rmoy1hzucnlaxsstwh	2020-11-23 22:06:30.467424
333	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:16:39.17376	5ptbe0rmoy1hzucnlaxsstwh	2020-11-24 09:52:36.611911
352	2	192.168.0.107	A81E84BE50F1	2020-11-24 16:28:19.570294	wkbxseictiuqmta4ymqc0zyq	2020-11-24 16:31:56.173696
334	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:17:54.129091	5ptbe0rmoy1hzucnlaxsstwh	2020-11-24 16:50:52.560646
335	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:24:27.581207	5ptbe0rmoy1hzucnlaxsstwh	2020-11-25 15:07:20.236067
336	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:25:49.324177	5ptbe0rmoy1hzucnlaxsstwh	2020-11-25 17:25:04.218409
337	1	192.168.0.107	A81E84BE50F1	2020-11-20 23:27:48.819297	5ptbe0rmoy1hzucnlaxsstwh	2020-11-25 17:44:40.089971
338	1	127.0.0.1	A81E84BE50F1	2020-11-22 10:08:48.314106	5pgh1jkyl3cpfory3v01kewj	2020-11-25 17:47:51.839189
339	1	192.168.0.107	A81E84BE50F1	2020-11-23 13:47:27.145716	xpiynth2sf3dhwqnz5m3mtmh	2020-11-25 17:51:20.518162
340	1	192.168.0.107	A81E84BE50F1	2020-11-23 16:25:56.486101	dwugi1b5f5razst5lfa4yc0m	2020-11-25 17:58:39.354588
341	1	192.168.0.107	A81E84BE50F1	2020-11-23 16:28:42.525935	dwugi1b5f5razst5lfa4yc0m	2020-11-25 18:00:32.686142
342	1	192.168.0.107	A81E84BE50F1	2020-11-23 17:02:11.749699	dwugi1b5f5razst5lfa4yc0m	2020-11-25 18:01:59.461938
343	1	192.168.0.107	A81E84BE50F1	2020-11-23 17:04:08.911547	dwugi1b5f5razst5lfa4yc0m	2020-11-25 18:07:20.049485
344	1	192.168.0.107	A81E84BE50F1	2020-11-23 17:07:37.866117	dwugi1b5f5razst5lfa4yc0m	2020-11-25 18:12:15.683259
345	1	192.168.0.107	A81E84BE50F1	2020-11-23 17:22:33.939236	dwugi1b5f5razst5lfa4yc0m	2020-11-25 18:22:54.589922
346	1	192.168.0.107	A81E84BE50F1	2020-11-23 17:26:02.434525	dwugi1b5f5razst5lfa4yc0m	2020-11-25 18:26:12.326367
348	1	192.168.0.107	A81E84BE50F1	2020-11-23 21:58:43.37802	sa5xukt3eixi0odr0so1krbk	2020-11-25 20:40:30.209743
349	1	192.168.0.107	A81E84BE50F1	2020-11-23 22:03:58.295993	i22djvah4spzk2l0q43stiyw	2020-11-25 21:04:58.366825
350	1	192.168.0.107	A81E84BE50F1	2020-11-23 22:05:57.731934	sfj3c15fufxmcqhlbk23icw2	2020-11-25 21:06:27.194018
347	1	192.168.0.107	A81E84BE50F1	2020-11-23 21:53:50.882004	ftarefpeytgcik0tc2a3bjlu	2020-11-25 18:27:56.836452
351	1	192.168.0.107	A81E84BE50F1	2020-11-24 09:39:23.672248	edjosa23ircspnmxbbl5shws	2020-11-27 17:21:18.863425
355	1	192.168.0.107	A81E84BE50F1	2020-11-24 16:48:37.662231	z1rwss0f42v0qe0qvo5m0wy1	2020-11-27 17:26:22.350709
356	1	192.168.0.107	A81E84BE50F1	2020-11-25 15:07:02.587596	00eyb2sixdumz0dviu03hsyq	2020-11-30 15:16:43.96338
357	1	192.168.0.107	A81E84BE50F1	2020-11-25 17:22:05.075828	00eyb2sixdumz0dviu03hsyq	2020-11-30 17:42:52.164213
358	1	192.168.0.107	A81E84BE50F1	2020-11-25 17:44:09.30157	00eyb2sixdumz0dviu03hsyq	2020-11-30 17:52:29.707196
359	1	192.168.0.107	A81E84BE50F1	2020-11-25 17:46:28.22706	00eyb2sixdumz0dviu03hsyq	2020-11-30 18:02:02.94101
360	1	192.168.0.107	A81E84BE50F1	2020-11-25 17:50:34.607414	00eyb2sixdumz0dviu03hsyq	2020-11-30 18:59:36.584658
361	1	192.168.0.107	A81E84BE50F1	2020-11-25 17:56:52.542854	00eyb2sixdumz0dviu03hsyq	2020-11-30 19:03:09.599438
362	1	192.168.0.107	A81E84BE50F1	2020-11-25 17:59:38.457485	00eyb2sixdumz0dviu03hsyq	2020-11-30 19:10:57.622939
384	1	192.168.0.107	A81E84BE50F1	2020-11-30 19:21:19.833662	gurpkt3iddixtbiqvxvqckpj	2020-11-30 19:21:36.645538
\.


                                                                                                                                                                                                                                                                                              2982.dat                                                                                            0000600 0004000 0002000 00000143315 13761310104 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        7	2	192.168.1.8	68F728DA75A0	2020-10-19 12:17:56.12275	2tqvruax3ajn2yqwxsgnm25m	2020-10-19 12:21:04.4734
9	3	192.168.1.8	68F728DA75A0	2020-10-21 17:04:21.825702	mr3rgziz0xx4a31tky14ofzg	2020-10-21 17:08:50.265323
11	4	192.168.1.8	68F728DA75A0	2020-10-21 17:10:06.063341	mr3rgziz0xx4a31tky14ofzg	2020-10-21 17:10:06.225247
49	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:33:08.712514	h3gbtludwaagjkslhhnvawdm	2020-10-22 18:36:09.343026
21	7	192.168.0.107	A81E84BE50F1	2020-10-22 16:57:00.132512	5wqxtfjw4pcb3wyjtznncexk	2020-10-22 16:57:08.012731
22	4	192.168.0.107	A81E84BE50F1	2020-10-22 16:57:28.045111	5wqxtfjw4pcb3wyjtznncexk	2020-10-22 16:57:39.674662
23	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:01:22.931641	aztn1v1qmv3x4o3hwbog3tv2	2020-10-22 17:01:24.240767
24	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:06:53.128078	prv5ao2bwg3z3h50swr41rog	2020-10-22 17:06:54.712872
25	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:19:27.350739	un5j1cd3qx4mezfrbfrci4ov	2020-10-22 17:19:50.994296
27	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:33:01.112959	z0zceli3gybdikcpyhtmi52q	2020-10-22 17:43:36.329095
31	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:46:29.48888	xqqz0qbuhlj2tv3xxgpnt2f5	2020-10-22 17:56:33.086179
36	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:57:04.372331	fannglnxentgifz5h5tfalcr	2020-10-22 17:57:06.469929
37	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:57:36.28223	fannglnxentgifz5h5tfalcr	2020-10-22 17:59:07.181644
38	7	192.168.0.107	A81E84BE50F1	2020-10-22 17:59:43.673123	fannglnxentgifz5h5tfalcr	2020-10-22 17:59:56.225586
39	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:02:11.914309	dxskcyufr3v4yuyjd5ovvzmw	2020-10-22 18:02:21.714138
40	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:02:53.036883	h0wmaegn1k3fckdajez5xnsn	2020-10-22 18:04:18.174473
41	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:03:54.756106	y3deepgx5pn3durbxslk3wbn	2020-10-22 18:04:50.291416
42	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:04:37.323233	dvnc32kgcj15iah5vac0qgno	2020-10-22 18:06:21.411025
43	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:06:07.856997	tvap1eiwqzlpnzj1o0bp52aa	2020-10-22 18:08:20.467086
44	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:07:56.245009	cw1mmkcsiicisfl33tb450d0	2020-10-22 18:08:56.500025
45	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:08:50.639783	uep25ctfs0fzuqkzdxbanr1s	2020-10-22 18:10:02.774333
46	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:09:45.046832	4rnfgxffwsdbys2vtcdy4yff	2020-10-22 18:27:39.851591
47	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:26:05.555968	1ttvcjmjvuft3uvosy3z1c20	2020-10-22 18:31:54.347068
48	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:31:46.455354	14kfhbsdso1ntr3faxorc0yf	2020-10-22 18:35:03.309758
50	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:35:58.655873	vvdupplzuaz4hnhmiwtq3kg3	2020-10-22 18:37:54.696987
51	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:36:41.320941	el1ozbxbbxpm01ayhps4oacv	2020-10-22 18:39:13.316486
52	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:37:42.311337	jvmldavo41zyfqe0q0axghqe	2020-10-22 18:40:31.936129
53	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:38:58.775445	2wfzgttmfsesdavwqxr4qzay	2020-10-22 18:44:19.722398
54	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:40:19.843492	dv1kqzkbjd4rmsgw15cosfkc	2020-10-22 18:44:49.120681
55	7	192.168.0.107	A81E84BE50F1	2020-10-22 18:43:20.002694	fnntll2p0kg4knlijalfcxiu	2020-10-23 11:54:06.448772
59	7	192.168.0.107	A81E84BE50F1	2020-10-23 12:05:46.085408	qz2u5hsdmeoddhf4bh1nqkt2	2020-10-23 12:05:53.345019
60	7	192.168.0.107	A81E84BE50F1	2020-10-23 12:13:07.300591	1jvesxplhgrvwabnhtvygfbn	2020-10-23 12:13:07.479823
77	7	192.168.0.107	A81E84BE50F1	2020-10-26 11:56:44.692426	f1mjwq4ouck5ygi04axyy3cz	2020-10-26 11:56:50.864136
78	4	192.168.0.107	A81E84BE50F1	2020-10-26 12:06:29.782594	52jijkog4td2gjbr145qjpjf	2020-10-26 12:06:32.169009
79	7	192.168.1.8	68F728DA75A0	2020-10-26 12:14:41.225107	bophzahwugdpu35xzcxkoeft	2020-10-26 12:15:31.874206
82	4	192.168.1.8	68F728DA75A0	2020-10-28 11:27:21.43563	bophzahwugdpu35xzcxkoeft	2020-10-28 11:27:24.147666
83	2	192.168.1.8	68F728DA75A0	2020-10-28 18:31:12.657894	bophzahwugdpu35xzcxkoeft	2020-10-28 18:32:38.388867
84	8	192.168.1.8	68F728DA75A0	2020-10-28 18:34:51.935783	bophzahwugdpu35xzcxkoeft	2020-10-28 18:37:09.47645
85	7	192.168.0.107	A81E84BE50F1	2020-10-28 19:17:27.732384	dvpnakag0hg1lips5kgs43m5	2020-10-28 19:18:05.418898
86	7	192.168.0.107	A81E84BE50F1	2020-10-28 19:19:02.119229	fqypvcknep2h0sl2m4eldqbu	2020-10-28 19:19:26.09767
87	7	192.168.0.107	A81E84BE50F1	2020-10-28 19:20:41.230904	ymjeriuddu1vbtmkj41pdqpd	2020-10-28 19:20:54.663322
88	7	192.168.0.107	A81E84BE50F1	2020-10-28 19:21:54.754798	ubmcmu4isnft3zqhjcrhu321	2020-10-28 19:22:07.954375
89	2	192.168.0.107	A81E84BE50F1	2020-10-28 19:30:58.297011	dkntzi2t1yuuzsh3eak3ecjx	2020-10-28 19:32:07.442246
90	2	192.168.0.107	A81E84BE50F1	2020-10-28 19:31:52.175839	uv4abzbaf3q31d3hcljx24va	2020-10-28 19:33:13.947108
91	2	192.168.0.107	A81E84BE50F1	2020-10-28 19:33:05.403929	5mgicsxn4msfw3ryw20yhssn	2020-10-28 19:35:16.859086
92	2	192.168.0.107	A81E84BE50F1	2020-10-28 19:35:07.352364	fajng43b4o5dbbfpgdoc0p1x	2020-10-28 19:36:43.651488
138	7	127.0.0.1	A81E84BE50F1	2020-10-29 17:41:54.946831	hp1sneqtr005pw03sntrpshp	2020-10-29 17:42:07.881149
140	7	192.168.0.107	A81E84BE50F1	2020-10-29 19:54:21.316822	24ohpkkss02z1oyftb4zwudj	2020-10-29 19:55:44.058585
141	7	192.168.0.107	A81E84BE50F1	2020-10-29 19:57:27.200242	ciexpcioqp3pmn11ffwxmcwv	2020-10-29 19:57:41.232108
143	7	192.168.0.107	A81E84BE50F1	2020-10-30 15:20:00.619015	tic1htho5btekx4bd2qfdcu2	2020-10-30 15:20:13.516315
146	7	192.168.0.107	A81E84BE50F1	2020-10-30 15:47:55.344814	ww4pqdj4mwjdimajcawpgfnq	2020-10-30 15:49:09.593707
151	7	192.168.0.107	A81E84BE50F1	2020-10-30 16:04:27.501716	2stqdixfu3owoftoxqiirmkr	2020-10-30 16:04:42.694987
152	2	192.168.0.107	A81E84BE50F1	2020-10-30 16:04:48.885439	2stqdixfu3owoftoxqiirmkr	2020-10-30 16:05:42.643436
153	7	192.168.0.107	A81E84BE50F1	2020-10-30 16:08:38.386433	xj05cpmvh1pdyzlo1wzae4vj	2020-10-30 16:08:52.057621
155	7	192.168.0.107	A81E84BE50F1	2020-10-30 16:40:24.420125	3sxbxq51i0fkkss4hjgtjguk	2020-10-30 16:40:36.511772
139	7	127.0.0.1	A81E84BE50F1	2020-10-29 17:57:01.612568	gkrxafgkcqt1usy55nshg0lg	2020-10-29 17:57:41.318375
142	7	192.168.0.107	A81E84BE50F1	2020-10-30 15:18:02.943181	sy454qencqctpxrb1l3jl2fk	2020-10-30 15:18:55.170176
144	7	192.168.0.107	A81E84BE50F1	2020-10-30 15:33:20.394407	lrwte4z5iq4l5te0dopzl3ui	2020-10-30 15:33:47.717433
145	2	192.168.0.107	A81E84BE50F1	2020-10-30 15:33:53.07586	lrwte4z5iq4l5te0dopzl3ui	2020-10-30 15:34:20.190219
147	7	192.168.0.107	A81E84BE50F1	2020-10-30 15:58:55.021763	cg25ju1klojgacvomajh2unc	2020-10-30 15:59:13.69937
148	7	192.168.0.107	A81E84BE50F1	2020-10-30 15:59:49.345798	dqpdiod2shpubmdlbvmasbjl	2020-10-30 16:01:02.302119
149	7	192.168.0.107	A81E84BE50F1	2020-10-30 16:02:01.080342	hl0wd1avfu5dxcrnepr5wskz	2020-10-30 16:02:17.091838
150	7	192.168.0.107	A81E84BE50F1	2020-10-30 16:03:37.513222	uw3atdqb5owllpxbwoqlya4u	2020-10-30 16:03:43.843618
154	7	192.168.0.107	A81E84BE50F1	2020-10-30 16:09:58.778016	xj05cpmvh1pdyzlo1wzae4vj	2020-10-30 16:11:00.536321
136	7	127.0.0.1	A81E84BE50F1	2020-10-29 17:17:07.807778	mjmt5ef5fy5gcttwauljxhv3	2020-10-29 17:17:14.780751
137	7	127.0.0.1	A81E84BE50F1	2020-10-29 17:19:27.045892	wofnxwtl0vuj1e34xlukas2j	2020-10-29 17:19:44.457524
156	2	192.168.1.8	68F728DA75A0	2020-10-30 17:04:11.957582	bophzahwugdpu35xzcxkoeft	2020-10-30 17:04:47.509566
157	2	192.168.1.8	68F728DA75A0	2020-10-31 10:20:39.734928	wglodghifhhgltbhqpogc1m4	2020-10-31 10:21:33.917061
158	7	192.168.0.107	A81E84BE50F1	2020-11-04 17:32:08.943116	vqzvf0oidlphveujgwkfmnxb	2020-11-04 17:33:25.069694
159	7	192.168.0.107	A81E84BE50F1	2020-11-04 20:17:40.919101	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:18:01.257221
160	7	192.168.0.107	A81E84BE50F1	2020-11-04 20:48:55.662903	vqzvf0oidlphveujgwkfmnxb	2020-11-04 20:49:34.683794
161	7	192.168.0.107	A81E84BE50F1	2020-11-05 18:43:09.052548	sg1o3muhxyrclw0lsevsvgft	2020-11-05 19:03:01.028691
162	7	192.168.0.107	A81E84BE50F1	2020-11-08 14:39:52.551302	bwjavm3ypi5lsi4pofuwjqsq	2020-11-08 14:45:43.342016
165	4	192.168.0.107	A81E84BE50F1	2020-11-08 15:03:34.947005	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:04:30.816255
163	7	192.168.0.107	A81E84BE50F1	2020-11-08 14:42:35.014447	ehry2z0cjlw3q01fdasttivv	2020-11-08 15:09:00.128644
164	7	192.168.0.107	A81E84BE50F1	2020-11-08 14:44:46.018926	0obrescmnmf4gjfb5ryyidsz	2020-11-08 15:13:27.363968
166	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:08:22.279931	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:22:06.656317
167	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:12:15.594645	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:24:49.349644
168	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:20:37.854356	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:30:30.983858
169	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:21:26.967475	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:36:22.331275
170	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:23:57.963212	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:38:17.95707
171	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:28:06.066207	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:42:57.136946
172	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:28:40.97134	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:44:09.282492
173	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:35:40.530611	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:49:50.70024
174	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:37:48.362876	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:50:08.80856
175	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:42:39.158823	tljbenmiftbe4ktlqsuj2eru	2020-11-08 15:51:40.469659
176	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:44:00.64526	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:05:11.758841
177	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:48:49.727311	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:06:37.053193
178	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:49:54.201542	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:09:23.104778
179	7	192.168.0.107	A81E84BE50F1	2020-11-08 15:51:04.185788	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:26:06.400658
180	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:03:40.693855	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:32:23.105848
181	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:06:09.531575	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:34:55.641512
182	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:08:26.383135	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:39:19.400766
183	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:25:10.390647	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:40:07.934131
184	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:31:46.566372	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:41:03.751926
185	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:34:11.025959	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:42:00.554953
186	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:38:55.415502	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:45:25.985628
187	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:39:54.566934	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:46:53.858352
188	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:40:41.413449	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:47:40.042898
189	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:41:39.567628	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:49:05.843214
190	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:45:00.246349	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:49:58.470661
191	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:46:03.341254	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:52:08.617565
192	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:47:26.274793	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:55:32.361245
193	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:48:52.15097	tljbenmiftbe4ktlqsuj2eru	2020-11-08 16:58:03.610732
194	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:49:43.528232	tljbenmiftbe4ktlqsuj2eru	2020-11-08 17:01:11.737519
195	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:51:55.487383	tljbenmiftbe4ktlqsuj2eru	2020-11-08 17:02:20.056395
196	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:55:22.011279	tljbenmiftbe4ktlqsuj2eru	2020-11-08 17:23:27.94515
197	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:56:46.430856	tljbenmiftbe4ktlqsuj2eru	2020-11-08 17:34:26.771036
198	7	192.168.0.107	A81E84BE50F1	2020-11-08 16:59:11.211504	tljbenmiftbe4ktlqsuj2eru	2020-11-09 15:19:46.096737
199	7	192.168.0.107	A81E84BE50F1	2020-11-08 17:01:01.27877	tljbenmiftbe4ktlqsuj2eru	2020-11-09 15:30:11.581459
200	7	192.168.0.107	A81E84BE50F1	2020-11-08 17:02:07.732391	tljbenmiftbe4ktlqsuj2eru	2020-11-09 15:32:51.964412
201	7	192.168.0.107	A81E84BE50F1	2020-11-08 17:13:23.849761	tljbenmiftbe4ktlqsuj2eru	2020-11-09 15:42:09.546829
202	7	192.168.0.107	A81E84BE50F1	2020-11-08 17:14:58.193481	tljbenmiftbe4ktlqsuj2eru	2020-11-09 15:45:58.849454
203	7	192.168.0.107	A81E84BE50F1	2020-11-08 17:16:47.461108	tljbenmiftbe4ktlqsuj2eru	2020-11-09 15:52:37.919691
204	7	192.168.0.107	A81E84BE50F1	2020-11-08 17:20:20.111966	tljbenmiftbe4ktlqsuj2eru	2020-11-09 16:03:21.818348
205	7	192.168.0.107	A81E84BE50F1	2020-11-08 17:34:15.527078	tljbenmiftbe4ktlqsuj2eru	2020-11-09 16:05:59.100858
207	7	192.168.0.107	A81E84BE50F1	2020-11-09 15:25:05.324447	gwrc0kszuybbpdyz0avwwyti	2020-11-09 16:20:13.116258
208	7	192.168.0.107	A81E84BE50F1	2020-11-09 15:32:02.472124	gwrc0kszuybbpdyz0avwwyti	2020-11-09 16:21:17.050697
209	7	192.168.0.107	A81E84BE50F1	2020-11-09 15:41:36.15653	gwrc0kszuybbpdyz0avwwyti	2020-11-09 16:44:20.795697
211	7	192.168.0.107	A81E84BE50F1	2020-11-09 15:52:29.93244	gwrc0kszuybbpdyz0avwwyti	2020-11-09 16:50:41.558199
212	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:00:47.48126	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:03:11.762864
206	7	192.168.0.107	A81E84BE50F1	2020-11-09 15:17:38.431559	gwrc0kszuybbpdyz0avwwyti	2020-11-09 16:19:30.378571
210	7	192.168.0.107	A81E84BE50F1	2020-11-09 15:45:52.948409	gwrc0kszuybbpdyz0avwwyti	2020-11-09 16:46:14.019925
213	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:01:09.914666	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:09:55.513657
214	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:05:42.278955	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:11:27.996971
215	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:18:49.042465	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:14:46.041542
216	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:19:48.254577	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:45:25.620319
217	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:20:38.56412	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:56:52.673102
218	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:43:39.644429	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:57:49.066254
219	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:45:29.773793	gwrc0kszuybbpdyz0avwwyti	2020-11-09 17:59:48.944254
220	7	192.168.0.107	A81E84BE50F1	2020-11-09 16:48:05.406733	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:01:11.439188
221	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:02:19.013937	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:03:53.097039
222	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:08:37.295075	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:07:28.756483
223	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:11:00.21698	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:09:24.160168
224	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:13:32.137294	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:10:16.424757
225	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:40:54.402668	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:14:36.616695
226	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:42:01.666606	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:19:43.722578
227	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:42:45.89726	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:21:32.73839
228	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:43:28.095885	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:23:01.968629
229	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:44:20.710156	gwrc0kszuybbpdyz0avwwyti	2020-11-09 18:26:10.915913
230	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:56:38.203848	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:15:01.636941
231	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:57:41.037857	gwrc0kszuybbpdyz0avwwyti	2020-11-09 20:57:48.470269
232	7	192.168.0.107	A81E84BE50F1	2020-11-09 17:59:41.798274	gwrc0kszuybbpdyz0avwwyti	2020-11-10 07:59:15.485957
233	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:00:45.331761	gwrc0kszuybbpdyz0avwwyti	2020-11-10 08:01:09.849827
234	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:03:16.0061	gwrc0kszuybbpdyz0avwwyti	2020-11-10 08:36:42.954271
235	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:07:02.268792	gwrc0kszuybbpdyz0avwwyti	2020-11-10 08:38:04.464826
236	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:09:09.648916	gwrc0kszuybbpdyz0avwwyti	2020-11-10 08:40:33.505121
237	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:10:08.231188	gwrc0kszuybbpdyz0avwwyti	2020-11-10 08:58:37.282778
238	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:14:24.849696	gwrc0kszuybbpdyz0avwwyti	2020-11-10 09:01:59.587371
239	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:19:26.864252	gwrc0kszuybbpdyz0avwwyti	2020-11-10 09:14:11.940686
240	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:21:24.99438	gwrc0kszuybbpdyz0avwwyti	2020-11-10 09:22:59.843617
241	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:22:29.208031	gwrc0kszuybbpdyz0avwwyti	2020-11-10 09:27:30.457636
242	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:25:07.172235	gwrc0kszuybbpdyz0avwwyti	2020-11-10 09:32:33.148076
243	7	192.168.0.107	A81E84BE50F1	2020-11-09 18:33:47.578081	gwrc0kszuybbpdyz0avwwyti	2020-11-10 09:52:42.096377
244	7	192.168.0.107	A81E84BE50F1	2020-11-09 19:54:30.36582	gwrc0kszuybbpdyz0avwwyti	2020-11-10 10:23:17.207693
245	7	192.168.0.107	A81E84BE50F1	2020-11-09 19:58:23.444784	gwrc0kszuybbpdyz0avwwyti	2020-11-10 12:33:20.091412
246	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:07:04.079859	gwrc0kszuybbpdyz0avwwyti	2020-11-10 12:35:32.850314
247	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:08:00.108618	gwrc0kszuybbpdyz0avwwyti	2020-11-10 12:45:33.871009
248	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:09:05.939203	gwrc0kszuybbpdyz0avwwyti	2020-11-10 13:03:38.864184
249	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:10:32.017595	gwrc0kszuybbpdyz0avwwyti	2020-11-10 14:38:16.784191
250	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:14:15.708964	gwrc0kszuybbpdyz0avwwyti	2020-11-10 14:57:30.226957
251	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:36:53.425403	gwrc0kszuybbpdyz0avwwyti	2020-11-10 15:13:59.516809
253	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:37:34.039073	gwrc0kszuybbpdyz0avwwyti	2020-11-10 15:16:58.619134
254	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:57:37.865188	gwrc0kszuybbpdyz0avwwyti	2020-11-10 15:21:47.25225
255	7	192.168.0.107	A81E84BE50F1	2020-11-09 21:12:02.720253	gwrc0kszuybbpdyz0avwwyti	2020-11-10 15:24:38.915127
256	7	192.168.0.107	A81E84BE50F1	2020-11-09 21:12:06.791183	gwrc0kszuybbpdyz0avwwyti	2020-11-10 15:27:49.135164
258	7	192.168.0.107	A81E84BE50F1	2020-11-10 08:00:04.572615	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:36:27.880334
259	7	192.168.0.107	A81E84BE50F1	2020-11-10 08:36:08.982335	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:39:21.523877
260	7	192.168.0.107	A81E84BE50F1	2020-11-10 08:37:28.051195	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:42:16.715178
262	7	192.168.0.107	A81E84BE50F1	2020-11-10 08:58:18.961576	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:50:16.835674
263	7	192.168.0.107	A81E84BE50F1	2020-11-10 09:01:02.393418	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:52:33.831188
264	7	192.168.0.107	A81E84BE50F1	2020-11-10 09:13:31.292763	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:55:52.382072
265	7	192.168.0.107	A81E84BE50F1	2020-11-10 09:21:42.839007	0ag3nlfm1gzslnhq025z1lta	2020-11-10 16:04:02.480843
267	7	192.168.0.107	A81E84BE50F1	2020-11-10 09:30:44.840567	0ag3nlfm1gzslnhq025z1lta	2020-11-10 16:37:01.289496
268	7	192.168.0.107	A81E84BE50F1	2020-11-10 09:52:01.539058	0ag3nlfm1gzslnhq025z1lta	2020-11-10 16:37:23.452362
269	7	192.168.0.107	A81E84BE50F1	2020-11-10 10:22:58.463331	uxtbvwj5l21tpwo3pbx4t02u	2020-11-10 16:39:26.091793
270	7	192.168.0.107	A81E84BE50F1	2020-11-10 12:32:20.148678	jpfs5tuirqdsgi0uopa3rlki	2020-11-10 17:02:36.149334
272	7	192.168.0.107	A81E84BE50F1	2020-11-10 12:44:58.676147	e24g3snrjt10h2hh32stu2bw	2020-11-10 19:25:53.916118
273	7	192.168.0.107	A81E84BE50F1	2020-11-10 13:03:25.871888	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-10 19:27:08.928072
274	7	192.168.0.107	A81E84BE50F1	2020-11-10 14:36:57.666447	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-10 19:30:45.661208
252	7	192.168.0.107	A81E84BE50F1	2020-11-09 20:36:57.894202	gwrc0kszuybbpdyz0avwwyti	2020-11-10 15:16:16.535219
257	7	192.168.0.107	A81E84BE50F1	2020-11-10 07:57:54.099368	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:32:44.426935
261	7	192.168.0.107	A81E84BE50F1	2020-11-10 08:38:54.043505	0ag3nlfm1gzslnhq025z1lta	2020-11-10 15:43:14.13187
266	7	192.168.0.107	A81E84BE50F1	2020-11-10 09:25:31.826433	0ag3nlfm1gzslnhq025z1lta	2020-11-10 16:35:05.690407
271	7	192.168.0.107	A81E84BE50F1	2020-11-10 12:35:06.031418	fbme4wwsa0cvzzkdpgxky1hf	2020-11-10 17:05:54.172548
275	7	192.168.0.107	A81E84BE50F1	2020-11-10 14:57:11.761016	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:27:14.906381
276	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:03:16.698239	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:29:02.94915
277	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:08:57.549007	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:37:11.552791
278	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:10:09.862161	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:39:53.592102
279	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:12:58.100504	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:46:28.583425
280	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:13:28.904995	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:48:59.188784
281	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:14:52.599034	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:50:07.433116
282	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:15:39.014543	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 10:58:14.743726
283	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:16:50.13926	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:00:31.48512
284	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:20:25.195375	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:01:45.994517
285	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:23:35.950503	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:05:04.96817
286	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:27:14.650887	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:10:11.480329
287	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:32:30.880085	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:14:14.883181
288	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:35:35.302109	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:17:07.911834
289	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:38:59.810284	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:20:03.27765
290	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:41:47.715701	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:22:05.276593
291	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:42:37.020271	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:22:50.918174
292	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:47:38.755395	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:26:18.164309
293	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:52:18.238584	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:26:58.132444
294	7	192.168.0.107	A81E84BE50F1	2020-11-10 15:55:10.854491	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:27:48.637263
295	7	192.168.0.107	A81E84BE50F1	2020-11-10 16:03:27.809177	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:41:12.408494
296	7	192.168.0.107	A81E84BE50F1	2020-11-10 16:34:24.671549	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:42:44.05422
297	7	192.168.0.107	A81E84BE50F1	2020-11-10 16:36:53.492365	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:48:11.110529
298	7	192.168.0.107	A81E84BE50F1	2020-11-10 16:37:05.74065	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 11:50:06.334335
299	7	192.168.0.107	A81E84BE50F1	2020-11-10 16:38:54.826755	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 12:01:55.409411
301	7	192.168.0.107	A81E84BE50F1	2020-11-10 17:01:14.007828	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 12:05:18.496726
302	7	192.168.0.107	A81E84BE50F1	2020-11-10 17:05:16.812113	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 12:09:23.383234
303	7	192.168.0.107	A81E84BE50F1	2020-11-10 17:19:08.589282	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 12:15:40.988834
304	7	192.168.0.107	A81E84BE50F1	2020-11-10 18:58:23.113857	wzakb4uc1mljweuxmdoajnm5	2020-11-12 12:16:36.791346
306	7	192.168.0.107	A81E84BE50F1	2020-11-10 18:59:31.056737	3xlyjzh4bgdmc3kum5ghjfpi	2020-11-12 12:24:28.962643
307	7	192.168.0.107	A81E84BE50F1	2020-11-10 19:05:04.102953	jellav50lgqupsn4syjtoqwn	2020-11-12 12:27:05.3787
308	7	192.168.0.107	A81E84BE50F1	2020-11-10 19:12:51.970151	yr24gbway5gl4v3mofly5ocu	2020-11-12 12:31:42.027737
310	7	192.168.0.107	A81E84BE50F1	2020-11-10 19:26:57.619566	5pgvjz4kjigvlvkaz5gskqct	2020-11-12 12:34:29.468033
311	7	192.168.0.107	A81E84BE50F1	2020-11-10 19:29:23.184415	p0pnqky1h4aalnb0oxobxcnr	2020-11-12 12:41:41.565841
312	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:16:28.586255	fnrrzbutp0pxofr2rgnbnz3x	2020-11-12 12:50:53.945585
313	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:22:19.292188	hq0oumlb2jwhkfigg0i1wnam	2020-11-12 12:53:10.98409
315	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:28:52.692604	4jjg4rlyar0huumfg2ps1edb	2020-11-12 13:09:16.269677
316	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:37:03.871319	bjuwnctudiftcwecunikmodn	2020-11-12 13:11:40.698814
317	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:37:49.269266	bjuwnctudiftcwecunikmodn	2020-11-12 13:14:06.295045
318	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:46:19.867483	bjuwnctudiftcwecunikmodn	2020-11-12 13:15:31.530298
320	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:49:58.245236	bjuwnctudiftcwecunikmodn	2020-11-12 13:19:47.594286
321	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:58:00.226073	bjuwnctudiftcwecunikmodn	2020-11-12 13:21:11.887558
322	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:00:25.028995	bjuwnctudiftcwecunikmodn	2020-11-12 13:25:26.435011
324	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:04:56.95942	bjuwnctudiftcwecunikmodn	2020-11-12 13:30:53.556284
325	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:10:04.337632	bjuwnctudiftcwecunikmodn	2020-11-12 13:32:54.36514
326	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:14:09.54692	bjuwnctudiftcwecunikmodn	2020-11-12 13:35:28.848028
327	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:15:59.873421	bjuwnctudiftcwecunikmodn	2020-11-12 13:42:48.915667
329	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:21:55.610274	bjuwnctudiftcwecunikmodn	2020-11-12 13:44:44.288528
330	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:22:45.397203	bjuwnctudiftcwecunikmodn	2020-11-12 13:46:41.213437
331	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:26:08.380829	bjuwnctudiftcwecunikmodn	2020-11-12 13:55:15.807808
332	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:26:52.311809	bjuwnctudiftcwecunikmodn	2020-11-12 13:58:03.086377
334	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:41:00.07817	bjuwnctudiftcwecunikmodn	2020-11-12 14:14:25.59382
335	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:42:32.352861	bjuwnctudiftcwecunikmodn	2020-11-12 14:15:37.447493
336	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:48:04.505309	bjuwnctudiftcwecunikmodn	2020-11-12 14:16:53.924244
300	7	192.168.0.107	A81E84BE50F1	2020-11-10 16:43:56.62457	x0i4u3am2yw3zgg1b0yfy2iw	2020-11-12 12:04:04.099186
305	7	192.168.0.107	A81E84BE50F1	2020-11-10 18:58:30.043913	wzakb4uc1mljweuxmdoajnm5	2020-11-12 12:22:19.339345
309	7	192.168.0.107	A81E84BE50F1	2020-11-10 19:20:48.776017	epsk3ez55pdvqvb1adfk32kw	2020-11-12 12:32:36.055212
314	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:26:09.032224	25yleqgcn45a1wux3cfaoi53	2020-11-12 13:06:46.230225
319	7	192.168.0.107	A81E84BE50F1	2020-11-12 10:48:52.068496	bjuwnctudiftcwecunikmodn	2020-11-12 13:16:24.309996
323	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:01:40.157356	bjuwnctudiftcwecunikmodn	2020-11-12 13:29:12.214424
328	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:19:54.88552	bjuwnctudiftcwecunikmodn	2020-11-12 13:43:53.483317
333	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:27:31.36142	bjuwnctudiftcwecunikmodn	2020-11-12 14:00:20.736869
337	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:49:56.057566	bjuwnctudiftcwecunikmodn	2020-11-12 14:22:32.736171
338	7	192.168.0.107	A81E84BE50F1	2020-11-12 11:59:36.255941	bjuwnctudiftcwecunikmodn	2020-11-12 14:30:48.484052
339	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:01:50.455263	bjuwnctudiftcwecunikmodn	2020-11-12 14:31:29.540974
340	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:03:57.587648	bjuwnctudiftcwecunikmodn	2020-11-12 14:32:18.074536
341	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:04:55.803175	bjuwnctudiftcwecunikmodn	2020-11-12 14:34:13.347968
342	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:09:09.702112	bjuwnctudiftcwecunikmodn	2020-11-12 14:36:35.46022
343	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:15:12.386723	bjuwnctudiftcwecunikmodn	2020-11-12 14:39:03.435729
388	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:39:07.744204	l1l4c11bhu2rgpen00ffy1i4	2020-11-12 14:39:16.456023
344	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:16:17.421612	bjuwnctudiftcwecunikmodn	2020-11-12 14:39:41.851549
390	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:39:50.189935	l1l4c11bhu2rgpen00ffy1i4	2020-11-12 14:40:24.515331
345	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:21:49.493076	bjuwnctudiftcwecunikmodn	2020-11-12 14:41:01.614295
392	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:41:05.435243	l1l4c11bhu2rgpen00ffy1i4	2020-11-12 14:41:11.861114
393	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:42:34.073403	waxno3hery5pobbfoze2ignl	2020-11-12 14:43:58.531843
394	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:43:38.159005	4xwkm1sn4kjkr54eku2d0lyk	2020-11-12 14:52:00.205579
395	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:50:02.312207	vqmbu4wmd11bavolq0whgd0f	2020-11-12 14:52:46.660014
397	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:54:57.339048	vqmbu4wmd11bavolq0whgd0f	2020-11-12 14:56:43.443028
346	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:24:14.755112	bjuwnctudiftcwecunikmodn	2020-11-12 15:02:10.398547
347	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:26:45.135316	bjuwnctudiftcwecunikmodn	2020-11-12 15:39:23.288672
349	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:32:13.136733	bjuwnctudiftcwecunikmodn	2020-11-12 15:51:48.88765
350	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:34:17.343817	bjuwnctudiftcwecunikmodn	2020-11-12 15:53:37.119174
351	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:41:03.471371	bjuwnctudiftcwecunikmodn	2020-11-12 15:54:48.751819
352	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:50:40.443654	3vzjszum1f5umk4bslu3a3bl	2020-11-12 15:55:47.034179
354	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:05:54.072981	jrl4xfz2t4qjbcnqosgevw0z	2020-11-12 16:01:37.217586
355	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:08:55.783034	3qrdacloq3alhd35kmo3d4iv	2020-11-12 17:42:57.630303
356	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:11:29.400214	jr0bvws3qp35gzqs0ulmeaqw	2020-11-12 17:44:51.760001
357	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:13:57.323569	2eqlvyz3n4wmwskpsaw2udap	2020-11-12 17:53:10.87161
359	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:16:16.616117	e1v32jyoyvreec5povnx5plj	2020-11-12 18:38:04.408873
360	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:19:39.554667	oa5nzfvxtxmlblpnnk5re0jr	2020-11-12 18:44:05.990896
361	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:21:00.869036	dkttsirhl5p5kwj5kuncvrfg	2020-11-12 18:49:14.302166
363	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:29:00.488258	gdxtmx2l2c0v3mmaqne050lr	2020-11-13 16:18:36.9863
364	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:30:26.504152	eq4adayepn3uzmg05524pqad	2020-11-13 16:28:37.840946
365	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:32:39.038505	fcd514i1lrjkrgc4cnjsaj5r	2020-11-13 16:30:31.11154
366	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:35:01.338564	gaq5jlazgyutdlwwwrndbu2x	2020-11-16 18:41:27.027092
368	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:42:23.218952	5x5jw5tpk0m5fm0hpj5pa0hi	2020-11-16 18:57:39.252992
369	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:43:33.383742	ssn30pmhgodlxxpmgvhs11cy	2020-11-16 19:00:03.105534
370	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:44:35.533135	fiwbsdyuwz0p3nt4axiuwnqn	2020-11-16 19:21:00.153918
371	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:45:56.619277	fie3qlooznd5o0zczfkkhhew	2020-11-16 19:27:14.737991
373	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:50:38.757313	b40moigygpwvqv4be0ieh5xf	2020-11-16 19:33:58.413854
374	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:54:17.972056	x3szbmuevanstcxvnir1oth3	2020-11-16 19:35:39.848718
375	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:55:00.991444	3ltyi0b1oyden2v4s3kkcs2p	2020-11-16 19:53:45.063193
376	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:57:54.911723	hhywzgj1nszdlaeyxyl3zmoa	2020-11-16 19:55:01.413976
378	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:14:09.5388	agmyrdnujr1ebevggbpgr02r	2020-11-16 19:57:45.305268
379	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:15:23.090171	ku1ovddbvs2xoejpngq2he15	2020-11-16 19:59:37.978207
380	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:16:29.195583	hvx4ndzwmijuhwm1cge5sv3v	2020-11-16 20:04:13.144306
382	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:30:25.105685	irsvijvexmjllmopqetgat2o	2020-11-16 20:42:06.968582
383	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:31:17.22645	zvxcfvfyuji5vpppragxj1b2	2020-11-16 20:49:15.443635
384	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:32:08.982497	hu4bxvq0hp21tzd5iau5ed4u	2020-11-16 21:00:35.305434
385	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:33:28.859334	fpz0ontrb4z1bwucaobhiuaj	2020-11-16 22:55:11.094389
387	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:38:53.33095	l1l4c11bhu2rgpen00ffy1i4	2020-11-16 23:18:54.600665
389	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:39:19.880895	l1l4c11bhu2rgpen00ffy1i4	2020-11-17 08:07:29.760777
391	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:40:52.573426	l1l4c11bhu2rgpen00ffy1i4	2020-11-17 08:22:07.123108
396	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:52:35.176153	vqmbu4wmd11bavolq0whgd0f	2020-11-12 14:55:24.934172
398	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:56:18.642849	vqmbu4wmd11bavolq0whgd0f	2020-11-12 14:58:05.689917
399	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:57:55.442158	vqmbu4wmd11bavolq0whgd0f	2020-11-12 14:59:15.774936
400	4	192.168.0.107	A81E84BE50F1	2020-11-12 14:58:46.586692	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:03:07.201417
402	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:02:49.859498	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:03:54.354439
403	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:03:41.515099	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:06:17.165257
404	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:06:06.669249	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:08:50.707385
405	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:08:25.957786	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:10:19.599274
406	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:10:04.093005	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:12:16.953918
407	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:11:35.172536	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:17:06.513111
408	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:16:49.654981	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:23:38.363959
409	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:23:15.456097	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:24:57.611611
410	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:24:50.699089	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:31:04.817942
411	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:30:17.759917	vqmbu4wmd11bavolq0whgd0f	2020-11-12 15:41:14.471518
348	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:31:07.428208	bjuwnctudiftcwecunikmodn	2020-11-12 15:51:08.036544
353	7	192.168.0.107	A81E84BE50F1	2020-11-12 12:53:01.906434	f5vmoxkbwk1yxv4z1h0itmko	2020-11-12 16:00:03.118853
413	4	192.168.0.107	A81E84BE50F1	2020-11-12 15:40:28.242968	vqmbu4wmd11bavolq0whgd0f	2020-11-12 17:12:11.710489
421	4	192.168.0.107	A81E84BE50F1	2020-11-12 17:12:00.173297	vqmbu4wmd11bavolq0whgd0f	2020-11-12 17:39:42.983913
422	4	192.168.0.107	A81E84BE50F1	2020-11-12 17:35:38.229718	vqmbu4wmd11bavolq0whgd0f	2020-11-12 17:51:41.713361
358	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:15:21.719312	ky0rztf14t0fiqvyxawbuod5	2020-11-12 17:56:08.028416
423	4	192.168.0.107	A81E84BE50F1	2020-11-12 17:36:22.375166	vqmbu4wmd11bavolq0whgd0f	2020-11-12 18:24:49.546462
426	4	192.168.0.107	A81E84BE50F1	2020-11-12 17:50:28.06274	vqmbu4wmd11bavolq0whgd0f	2020-11-12 18:29:57.252768
427	4	192.168.0.107	A81E84BE50F1	2020-11-12 17:51:32.805637	vqmbu4wmd11bavolq0whgd0f	2020-11-12 18:33:34.679534
430	4	192.168.0.107	A81E84BE50F1	2020-11-12 18:24:40.855489	vqmbu4wmd11bavolq0whgd0f	2020-11-12 18:35:14.766574
431	4	192.168.0.107	A81E84BE50F1	2020-11-12 18:29:18.382936	vqmbu4wmd11bavolq0whgd0f	2020-11-12 18:37:33.198638
362	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:25:17.141674	hgyhwdxehwxcm5u5umsh5zb2	2020-11-12 18:49:57.698987
432	4	192.168.0.107	A81E84BE50F1	2020-11-12 18:33:16.276847	vqmbu4wmd11bavolq0whgd0f	2020-11-13 16:01:59.912513
440	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:06:33.561462	xiipsflluopj3xm4inwlsp3e	2020-11-13 16:07:19.494205
441	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:11:01.567932	jbwjmgwvspui1abvv5yverng	2020-11-13 16:11:58.202542
442	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:12:48.021078	nz1git2mlly5dpj5my2myark	2020-11-13 16:14:00.417822
443	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:13:42.729371	dadwarbezzinymnmnlfwob5i	2020-11-13 16:18:23.138218
444	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:17:31.159561	vczwrmwsfmhi0bj5r13hbo2g	2020-11-13 16:28:24.389805
446	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:27:43.150093	1eym5apearikpdivuv01o3u2	2020-11-13 16:32:20.721701
449	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:32:04.537286	bnlfswxm5nr2beybgjptu50j	2020-11-13 16:34:02.459241
450	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:33:48.501384	z0lpeeeioyxsdliwm5s0o4bf	2020-11-13 16:36:43.563474
452	8	192.168.0.107	A81E84BE50F1	2020-11-13 16:41:08.26668	rxqta23whwqh24i5qdzhpd3t	2020-11-13 16:42:08.580181
367	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:41:36.420398	ak4srvqnqyvxkmgmqvt5tleq	2020-11-16 18:55:33.677516
401	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:01:56.36387	vqmbu4wmd11bavolq0whgd0f	2020-11-17 08:23:58.421875
414	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:50:46.392656	vqmbu4wmd11bavolq0whgd0f	2020-11-17 09:13:57.023493
415	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:51:41.272499	vqmbu4wmd11bavolq0whgd0f	2020-11-17 09:19:24.385992
416	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:53:25.875792	vqmbu4wmd11bavolq0whgd0f	2020-11-17 09:22:25.465992
418	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:55:40.151072	vqmbu4wmd11bavolq0whgd0f	2020-11-17 09:35:15.835551
419	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:59:31.963045	vqmbu4wmd11bavolq0whgd0f	2020-11-17 09:42:55.984751
420	7	192.168.0.107	A81E84BE50F1	2020-11-12 16:00:37.455449	vqmbu4wmd11bavolq0whgd0f	2020-11-17 10:07:40.587833
424	7	192.168.0.107	A81E84BE50F1	2020-11-12 17:42:32.823089	vqmbu4wmd11bavolq0whgd0f	2020-11-17 10:12:43.427938
425	7	192.168.0.107	A81E84BE50F1	2020-11-12 17:44:18.772222	vqmbu4wmd11bavolq0whgd0f	2020-11-17 10:14:20.270688
428	7	192.168.0.107	A81E84BE50F1	2020-11-12 17:52:39.455894	vqmbu4wmd11bavolq0whgd0f	2020-11-17 17:08:48.13078
429	7	192.168.0.107	A81E84BE50F1	2020-11-12 17:55:46.919509	vqmbu4wmd11bavolq0whgd0f	2020-11-17 17:12:44.89465
435	7	192.168.0.107	A81E84BE50F1	2020-11-12 18:37:42.957356	vqmbu4wmd11bavolq0whgd0f	2020-11-17 17:21:44.716686
437	7	192.168.0.107	A81E84BE50F1	2020-11-12 18:48:44.874034	vqmbu4wmd11bavolq0whgd0f	2020-11-17 17:26:12.890328
438	7	192.168.0.107	A81E84BE50F1	2020-11-12 18:49:48.01857	vqmbu4wmd11bavolq0whgd0f	2020-11-17 17:38:41.587204
445	7	192.168.0.107	A81E84BE50F1	2020-11-13 16:18:26.089267	vczwrmwsfmhi0bj5r13hbo2g	2020-11-17 17:39:43.836086
447	7	192.168.0.107	A81E84BE50F1	2020-11-13 16:28:28.243524	1eym5apearikpdivuv01o3u2	2020-11-17 17:56:20.261073
453	7	192.168.0.107	A81E84BE50F1	2020-11-16 18:40:58.726982	zta5igwv3iwhec4pe2ty2akg	2020-11-17 18:14:34.623667
454	7	192.168.0.107	A81E84BE50F1	2020-11-16 18:54:55.46178	vs2iumrhshy0tjtwhkxuiqul	2020-11-17 18:24:01.684591
455	7	192.168.0.107	A81E84BE50F1	2020-11-16 18:57:18.957717	cjqztx1bvc5xegbmkpd3mgee	2020-11-17 18:37:05.312116
433	4	192.168.0.107	A81E84BE50F1	2020-11-12 18:35:05.873587	vqmbu4wmd11bavolq0whgd0f	2020-11-19 15:04:45.295719
372	7	192.168.0.107	A81E84BE50F1	2020-11-12 13:46:31.730104	zuxiyhx4fd25xsryuzlplb5f	2020-11-16 19:31:40.832676
377	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:00:11.775261	fpmo41okge4g1sottbca02py	2020-11-16 19:56:46.829866
381	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:22:16.491572	evgxbdqtqd1qgnjucxpul32z	2020-11-16 20:23:13.142142
386	7	192.168.0.107	A81E84BE50F1	2020-11-12 14:36:16.268196	gzugfpajrph21cztkbogmqek	2020-11-16 22:59:22.658042
412	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:38:40.508001	vqmbu4wmd11bavolq0whgd0f	2020-11-17 08:25:31.98414
417	7	192.168.0.107	A81E84BE50F1	2020-11-12 15:54:40.635421	vqmbu4wmd11bavolq0whgd0f	2020-11-17 09:25:55.336114
451	2	192.168.0.107	A81E84BE50F1	2020-11-13 16:35:49.649651	ni3q5zp20yp0km2hotoni4kz	2020-11-17 10:13:19.576976
436	7	192.168.0.107	A81E84BE50F1	2020-11-12 18:43:19.248449	vqmbu4wmd11bavolq0whgd0f	2020-11-17 17:23:17.497478
458	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:17:15.599242	qes353uaru254ysfyk5jds5i	2020-11-17 18:49:32.300932
459	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:17:20.148251	qes353uaru254ysfyk5jds5i	2020-11-17 18:50:54.243686
460	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:19:43.410363	k22ykccsemwf3bmukhzakrmy	2020-11-17 18:52:24.912426
462	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:30:43.662634	j2zs2xe0jljmgswyrisa2t2k	2020-11-17 19:00:53.54617
463	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:33:14.788673	yzevadko2vhaelqdr15fmqrb	2020-11-17 19:02:21.158186
464	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:34:42.368766	sp0zt443psp3u5wqlgcouiyv	2020-11-17 19:04:29.235429
465	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:40:06.435458	jcsdr3504djktuuyloicmc0y	2020-11-17 19:15:17.127558
467	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:56:07.047252	jcsdr3504djktuuyloicmc0y	2020-11-17 19:18:06.560562
468	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:57:17.549739	jcsdr3504djktuuyloicmc0y	2020-11-17 19:22:15.268484
469	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:59:01.704163	jcsdr3504djktuuyloicmc0y	2020-11-17 19:24:51.709697
471	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:04:50.62461	jcsdr3504djktuuyloicmc0y	2020-11-17 19:27:31.680703
472	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:11:28.665729	jcsdr3504djktuuyloicmc0y	2020-11-17 19:33:36.301902
473	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:23:31.038028	jcsdr3504djktuuyloicmc0y	2020-11-17 19:35:21.57356
474	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:23:54.177603	jcsdr3504djktuuyloicmc0y	2020-11-17 19:38:35.574492
476	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:27:41.296505	jcsdr3504djktuuyloicmc0y	2020-11-17 19:43:21.18699
477	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:33:09.60912	jcsdr3504djktuuyloicmc0y	2020-11-17 19:49:45.847473
478	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:37:11.348866	2e2duqzl3wsamekhki01pif4	2020-11-17 20:04:07.726869
479	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:40:56.613238	jrtqr5e0oqd4wtobvv4bh0kg	2020-11-17 20:40:13.741094
481	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:54:03.120721	bmcxwnkcz4a5oq0bx5pzgevk	2020-11-17 20:56:50.390228
482	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:55:15.81546	hsnicjj2auar2mqlq1ghtwmk	2020-11-17 21:00:26.648302
483	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:56:10.84337	big2drd4axuizsruz4tqcclm	2020-11-18 22:00:51.506262
485	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:58:46.353269	mgfszaj5nhms1hvdbmyg42kv	2020-11-19 13:43:36.364323
486	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:58:50.626093	mgfszaj5nhms1hvdbmyg42kv	2020-11-19 15:01:08.000933
487	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:00:26.753235	o0eyt5342tksmzdsnzwrb3zn	2020-11-19 17:08:43.446564
488	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:01:35.066257	t4xzve1txllb4kdjojyhlihx	2020-11-19 17:09:04.870327
512	2	192.168.0.107	A81E84BE50F1	2020-11-17 10:12:48.685026	if1om3kopna4w0it4c2yq0rp	2020-11-20 16:38:57.251021
490	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:03:09.169899	gjv2xzkj1zqrqlzewv3hsl1u	2020-11-20 21:52:59.120683
491	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:04:46.967096	n2ajx1b0lgemb1st1diexkty	2020-11-20 23:21:06.264115
492	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:06:55.18956	0wlrgye21rvbr04ulnsiitie	2020-11-23 17:44:46.355485
494	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:07:08.57763	0wlrgye21rvbr04ulnsiitie	2020-11-23 22:08:15.75452
495	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:07:16.835828	0wlrgye21rvbr04ulnsiitie	2020-11-24 09:51:33.087952
496	7	192.168.0.107	A81E84BE50F1	2020-11-16 22:51:23.995611	e1vwf2krpitrbsho3zrfe5w4	2020-11-24 16:10:15.03475
497	7	192.168.0.107	A81E84BE50F1	2020-11-16 22:58:24.037058	e1vwf2krpitrbsho3zrfe5w4	2020-11-24 16:19:00.737275
499	7	192.168.0.107	A81E84BE50F1	2020-11-17 08:07:13.28575	20z3cjsithbmu2wgdxcemkdm	2020-11-25 14:53:29.657855
500	7	192.168.0.107	A81E84BE50F1	2020-11-17 08:15:46.230816	luqpkyaxf4fv3zotl1lksdhz	2020-11-25 15:03:04.142859
501	7	192.168.0.107	A81E84BE50F1	2020-11-17 08:23:37.978954	luqpkyaxf4fv3zotl1lksdhz	2020-11-25 15:57:30.702907
503	7	192.168.0.107	A81E84BE50F1	2020-11-17 09:13:23.230099	x4nnsva3zoi0r5ablu2ic31p	2020-11-25 16:22:11.127198
504	7	192.168.0.107	A81E84BE50F1	2020-11-17 09:14:59.204018	balfyqbo24m1lcpqndcmf4id	2020-11-25 16:26:57.534038
505	7	192.168.0.107	A81E84BE50F1	2020-11-17 09:17:31.32875	3omyte0xkqroqdpmt1pz2ssm	2020-11-25 16:28:12.148865
506	7	192.168.0.107	A81E84BE50F1	2020-11-17 09:21:28.085729	vouffxpcb4l0zbsiikxoi2ak	2020-11-25 16:38:29.332577
508	7	192.168.0.107	A81E84BE50F1	2020-11-17 09:34:26.745384	n31mlbextapsggowzcxsr14b	2020-11-25 16:51:43.836
509	7	192.168.0.107	A81E84BE50F1	2020-11-17 09:42:10.728488	if1om3kopna4w0it4c2yq0rp	2020-11-25 16:56:03.684817
510	7	192.168.0.107	A81E84BE50F1	2020-11-17 10:06:36.377143	if1om3kopna4w0it4c2yq0rp	2020-11-25 17:02:35.508298
511	7	192.168.0.107	A81E84BE50F1	2020-11-17 10:11:40.521639	if1om3kopna4w0it4c2yq0rp	2020-11-25 17:06:13.464116
514	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:08:02.757381	w0frevgxqrqnbqhbg5e0qbuj	2020-11-25 17:11:28.353121
515	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:09:33.892966	m4kzzvsifanlywnbsfyfwiez	2020-11-25 17:14:45.428705
516	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:13:18.482994	jyr1gq02c0cc333nelssswda	2020-11-25 17:15:53.654504
518	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:25:43.087854	avkk3xf3uwmydvgulymnmzqm	2020-11-25 17:47:45.122068
519	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:38:03.905219	zxylb01eyugao0hoiw3hjora	2020-11-25 17:51:22.37904
520	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:39:14.422729	xm5ics0erbtq2at5pu3lngc4	2020-11-25 17:58:42.362578
521	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:54:32.445292	3pslquh23j0fi4alo1q4ziww	2020-11-25 18:00:27.806069
448	7	192.168.0.107	A81E84BE50F1	2020-11-13 16:29:05.193755	1eym5apearikpdivuv01o3u2	2020-11-17 18:12:53.594397
456	7	192.168.0.107	A81E84BE50F1	2020-11-16 18:59:16.092642	i2pf0cfe4zezpezxel0wnej1	2020-11-17 18:42:52.650036
457	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:17:09.478761	qes353uaru254ysfyk5jds5i	2020-11-17 18:47:31.794622
461	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:24:38.150821	p2gm5sfjhtl3y0ebk5acfdeo	2020-11-17 18:54:15.359217
466	7	192.168.0.107	A81E84BE50F1	2020-11-16 19:54:29.83115	jcsdr3504djktuuyloicmc0y	2020-11-17 19:17:15.794947
470	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:03:03.006898	jcsdr3504djktuuyloicmc0y	2020-11-17 19:26:36.030278
536	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:01:33.802806	2ikmqvsolim3fgofadeznnee	2020-11-30 15:49:48.152461
537	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:04:05.159394	2ikmqvsolim3fgofadeznnee	2020-11-30 17:52:27.771225
538	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:14:46.973685	2ikmqvsolim3fgofadeznnee	2020-11-30 18:02:06.238446
540	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:17:34.033929	2ikmqvsolim3fgofadeznnee	2020-11-30 19:03:06.18956
541	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:21:59.899958	2ikmqvsolim3fgofadeznnee	2020-11-30 19:13:06.359373
542	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:24:24.956172	2ikmqvsolim3fgofadeznnee	2020-11-30 19:15:22.170815
475	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:25:33.673043	jcsdr3504djktuuyloicmc0y	2020-11-17 19:39:04.9357
480	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:48:56.537162	svhhjwrcsnnrbhptw0q5fte3	2020-11-17 20:55:02.18885
484	7	192.168.0.107	A81E84BE50F1	2020-11-16 20:56:34.93174	k1adcki4eckqvj3cz0yi5l0y	2020-11-18 23:06:08.425171
489	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:02:28.481773	t4xzve1txllb4kdjojyhlihx	2020-11-20 16:37:30.751842
493	7	192.168.0.107	A81E84BE50F1	2020-11-16 21:07:00.743993	0wlrgye21rvbr04ulnsiitie	2020-11-23 17:48:17.191758
564	2	192.168.0.107	A81E84BE50F1	2020-11-20 16:37:35.154084	1kcrskpnrfgqldnu0sk55jam	2020-11-24 16:09:32.197559
498	7	192.168.0.107	A81E84BE50F1	2020-11-16 23:18:41.993587	rjk4sjr55b2bmdvl1z1taoiw	2020-11-24 17:00:14.151346
571	2	192.168.0.107	A81E84BE50F1	2020-11-24 16:08:56.457637	bqdepiqwmngexvs1asaho1mv	2020-11-24 17:05:08.262775
575	2	192.168.0.107	A81E84BE50F1	2020-11-24 17:04:27.5692	2lxo0py515bzrbtgp0oncvo1	2020-11-25 14:45:26.38629
523	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:14:01.650936	jldxl1apuqchnjnwy3th5owy	2020-11-25 18:07:17.047529
524	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:15:42.441629	4zrtzbib2jsz0rjvagdydye3	2020-11-25 18:12:18.940398
525	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:22:22.17065	my3nekjzquz0ls3uzxuz2zt2	2020-11-25 18:22:48.87528
526	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:25:23.518506	z02hhtssj0pxtban12uemo2k	2020-11-25 18:25:21.970626
528	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:31:19.419945	2ikmqvsolim3fgofadeznnee	2020-11-25 18:27:58.486797
529	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:40:29.026132	2ikmqvsolim3fgofadeznnee	2020-11-25 21:08:08.509902
530	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:43:35.122727	2ikmqvsolim3fgofadeznnee	2020-11-26 13:44:20.769175
531	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:49:04.503321	2ikmqvsolim3fgofadeznnee	2020-11-26 13:50:45.430906
533	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:52:02.364669	2ikmqvsolim3fgofadeznnee	2020-11-26 14:11:28.516112
534	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:53:18.434657	2ikmqvsolim3fgofadeznnee	2020-11-26 14:17:30.894906
502	7	192.168.0.107	A81E84BE50F1	2020-11-17 08:24:46.783362	xgld2vhcenipmm40kqrazwd4	2020-11-25 16:08:18.00239
507	7	192.168.0.107	A81E84BE50F1	2020-11-17 09:23:18.8124	vouffxpcb4l0zbsiikxoi2ak	2020-11-25 16:46:19.44299
513	7	192.168.0.107	A81E84BE50F1	2020-11-17 10:13:24.164509	if1om3kopna4w0it4c2yq0rp	2020-11-25 17:08:56.629764
517	7	192.168.0.107	A81E84BE50F1	2020-11-17 17:21:56.878747	jyr1gq02c0cc333nelssswda	2020-11-25 17:24:57.582907
522	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:11:19.020237	jzviwziglogaa0mvmt0vt2ip	2020-11-25 18:02:01.995558
527	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:29:14.936256	absoozo42lxvkasqvpkkmjo5	2020-11-25 18:26:08.845555
532	7	192.168.0.107	A81E84BE50F1	2020-11-17 18:50:34.956539	2ikmqvsolim3fgofadeznnee	2020-11-26 13:55:18.42096
535	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:00:29.59979	2ikmqvsolim3fgofadeznnee	2020-11-29 21:55:00.199571
539	7	192.168.0.107	A81E84BE50F1	2020-11-17 19:16:48.934671	2ikmqvsolim3fgofadeznnee	2020-11-30 18:59:30.90699
639	7	192.168.0.107	A81E84BE50F1	2020-11-30 19:22:36.410092	gurpkt3iddixtbiqvxvqckpj	2020-11-30 19:22:49.328592
640	7	192.168.0.107	A81E84BE50F1	2020-11-30 19:29:47.206163	gurpkt3iddixtbiqvxvqckpj	2020-11-30 19:31:09.654748
\.


                                                                                                                                                                                                                                                                                                                   2984.dat                                                                                            0000600 0004000 0002000 00000015621 13761310104 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	2020-10-12 17:48:52.091791	UPDATE	delux	cliente	sistema	postgres	{"contrasena_nuevo": "ivan09", "contrasena_anterior": "ivan"}	3
2	2020-10-12 17:54:13.87281	DELETE	delux	cliente	sistema	postgres	{"email_anterior": "alex123@gmail.com", "nombre_anterior": "ivan", "usuario_anterior": "ivan", "apellido_anterior": "preciado", "contrasena_anterior": "ivan09", "id_cliente_anterior": 3, "modificado_anterior": "sistema", "fecha_de_nacimiento_anterior": "1999-11-09"}	3
3	2020-10-12 18:26:25.857993	INSERT	delux	cliente	sistema	postgres	{"email_nuevo": "alexander@gmail.com", "nombre_nuevo": "Ivan Alexander", "usuario_nuevo": "jalex", "apellido_nuevo": "Preciado Horta", "contrasena_nuevo": "1234", "id_cliente_nuevo": 7, "modificado_nuevo": "sistema", "fecha_de_nacimiento_nuevo": "1999-11-09"}	7
4	2020-10-12 18:26:41.312148	DELETE	delux	cliente	sistema	postgres	{"email_anterior": "alexander@gmail.com", "nombre_anterior": "Ivan Alexander", "usuario_anterior": "jalex", "apellido_anterior": "Preciado Horta", "contrasena_anterior": "1234", "id_cliente_anterior": 7, "modificado_anterior": "sistema", "fecha_de_nacimiento_anterior": "1999-11-09"}	7
5	2020-10-12 18:32:18.605398	INSERT	delux	cliente	mototaxideluxe	postgres	{"email_nuevo": "amirriga@gmail.com", "nombre_nuevo": "Ana Milena", "usuario_nuevo": "amirriga", "apellido_nuevo": "Rios Gallego", "contrasena_nuevo": "anarios", "id_cliente_nuevo": 9, "modificado_nuevo": "mototaxideluxe", "fecha_de_nacimiento_nuevo": "1979-08-07"}	9
6	2020-10-12 18:34:12.624005	UPDATE	delux	cliente	mototaxideluxe	postgres	{"contrasena_nuevo": "anarios123", "contrasena_anterior": "anarios"}	9
7	2020-10-21 14:46:25.086331	UPDATE	delux	cliente	sistema	postgres	{}	1
8	2020-10-21 14:46:51.812277	UPDATE	delux	cliente	sistema	postgres	{}	1
9	2020-10-21 14:56:09.050158	UPDATE	delux	cliente	sistema	postgres	{}	2
10	2020-10-21 14:59:13.925025	UPDATE	delux	cliente	sistema	postgres	{}	2
11	2020-10-21 15:00:42.562418	UPDATE	delux	cliente	motodeluxe	postgres	{"modificado_nuevo": "motodeluxe", "modificado_anterior": "sistema"}	2
12	2020-10-21 15:01:12.116655	UPDATE	delux	cliente	motodeluxe	postgres	{}	2
13	2020-10-21 15:01:49.17697	UPDATE	delux	cliente	motodeluxe	postgres	{}	2
14	2020-10-21 15:11:37.884194	UPDATE	delux	cliente	sifuncionó	postgres	{"modificado_nuevo": "sifuncionó", "modificado_anterior": "motodeluxe"}	2
15	2020-10-21 15:14:15.100209	UPDATE	delux	cliente	sifuncionó	postgres	{}	2
16	2020-10-21 15:20:21.696789	UPDATE	delux	cliente	sifuncionó	postgres	{"nombre_nuevo": "Paula Alejandra", "apellido_nuevo": "Guzman Cruz", "nombre_anterior": "Alejandra", "apellido_anterior": "Guzman"}	2
17	2020-10-21 15:23:59.51733	UPDATE	delux	cliente	sifuncionó	postgres	{}	2
18	2020-10-21 15:51:10.466679	UPDATE	delux	cliente	sifuncionó	postgres	{}	2
19	2020-10-21 15:52:35.095721	UPDATE	delux	cliente	sifuncionó	postgres	{}	2
20	2020-10-21 16:01:26.602088	UPDATE	delux	cliente	sistema	postgres	{"nombre_nuevo": "James Daniel", "apellido_nuevo": "Alzate Rios", "nombre_anterior": "James", "apellido_anterior": "Alzate"}	1
21	2020-10-21 16:17:37.77875	UPDATE	delux	cliente	mototaxideluxe	postgres	{}	9
22	2020-10-21 16:21:07.054688	UPDATE	delux	cliente	sistema	postgres	{}	1
23	2020-10-21 16:21:07.054688	UPDATE	delux	cliente	sifuncionó	postgres	{}	2
24	2020-10-21 16:21:07.054688	UPDATE	delux	cliente	sistema	postgres	{}	4
25	2020-10-21 16:21:26.202383	UPDATE	delux	cliente	sistema	postgres	{"sesion_nuevo": "inactivo", "sesion_anterior": "activo"}	4
26	2020-10-21 16:26:18.78454	INSERT	delux	cliente	mototaxideluxe	postgres	{"email_nuevo": "ivanalexanderpreciado0702@gmail.com", "nombre_nuevo": "Ivan Alexander", "sesion_nuevo": "activo", "usuario_nuevo": "ivan", "apellido_nuevo": "Preciado Horta", "contrasena_nuevo": "0702", "id_cliente_nuevo": 10, "modificado_nuevo": "mototaxideluxe", "fecha_de_nacimiento_nuevo": "1999-11-09"}	10
27	2020-10-21 16:41:09.492764	UPDATE	delux	cliente	sistema	postgres	{"sesion_nuevo": "activo", "sesion_anterior": "inactivo"}	4
28	2020-10-21 16:42:37.535682	UPDATE	delux	cliente	sistema	postgres	{"nombre_nuevo": "Luz Mery", "nombre_anterior": "Mery", "contrasena_nuevo": "123", "contrasena_anterior": "mery"}	4
29	2020-10-21 16:43:26.370014	UPDATE	delux	cliente	sistema	postgres	{"sesion_nuevo": "inactivo", "sesion_anterior": "activo"}	4
30	2020-10-22 18:16:58.79735	UPDATE	delux	cliente	mototaxideluxe	postgres	{"nombre_nuevo": "Ivan", "apellido_nuevo": "Preciado", "nombre_anterior": "Ivan Alexander", "apellido_anterior": "Preciado Horta"}	10
31	2020-11-05 19:27:08.030111	INSERT	delux	cliente	mototaxideluxe	postgres	{"email_nuevo": "james.alzate22@gmail.com", "nombre_nuevo": "Daniel", "sesion_nuevo": "activo", "usuario_nuevo": "daniel", "apellido_nuevo": "Rios", "contrasena_nuevo": "daniel2", "id_cliente_nuevo": 11, "modificado_nuevo": "mototaxideluxe", "fecha_de_nacimiento_nuevo": "2001-04-02"}	11
32	2020-11-05 19:44:46.466184	INSERT	delux	cliente	mototaxideluxe	postgres	{"email_nuevo": "james@gmail.com", "nombre_nuevo": "James", "sesion_nuevo": "activo", "usuario_nuevo": "james444", "apellido_nuevo": "Rios", "contrasena_nuevo": "james1", "id_cliente_nuevo": 12, "modificado_nuevo": "mototaxideluxe", "fecha_de_nacimiento_nuevo": "2001-04-02"}	12
33	2020-11-10 17:43:42.296315	UPDATE	delux	cliente	sistema	postgres	{}	1
34	2020-11-10 17:43:42.296315	UPDATE	delux	cliente	sifuncionó	postgres	{}	2
35	2020-11-10 17:43:42.296315	UPDATE	delux	cliente	sistema	postgres	{}	4
36	2020-11-10 17:43:42.296315	UPDATE	delux	cliente	mototaxideluxe	postgres	{}	9
37	2020-11-10 17:43:42.296315	UPDATE	delux	cliente	mototaxideluxe	postgres	{}	10
38	2020-11-10 17:43:42.296315	UPDATE	delux	cliente	mototaxideluxe	postgres	{}	11
39	2020-11-10 17:43:42.296315	UPDATE	delux	cliente	mototaxideluxe	postgres	{}	12
40	2020-11-13 16:15:56.682387	UPDATE	delux	cliente	mototaxideluxe	postgres	{"sesion_nuevo": "activo", "sesion_anterior": "inactivo"}	9
41	2020-11-19 18:30:45.696193	INSERT	delux	cliente	mototaxideluxe	postgres	{"email_nuevo": "alzateriosanamaria@gmail.com", "nombre_nuevo": "Ana Maria", "sesion_nuevo": "activo", "usuario_nuevo": "anita", "apellido_nuevo": "Alzate Rios", "contrasena_nuevo": "1234", "id_cliente_nuevo": 13, "modificado_nuevo": "mototaxideluxe", "fecha_de_nacimiento_nuevo": "1997-09-05"}	13
42	2020-11-20 15:09:09.739058	UPDATE	delux	cliente	sifuncionó	postgres	{"sesion_nuevo": "sancionado", "sesion_anterior": "activo"}	2
43	2020-11-20 15:09:40.522179	UPDATE	delux	cliente	sifuncionó	postgres	{}	2
44	2020-11-24 09:29:00.348813	UPDATE	delux	cliente	sistema	postgres	{"sesion_nuevo": "sancionado", "sesion_anterior": "inactivo"}	4
45	2020-11-24 09:31:49.120729	UPDATE	delux	cliente	sifuncionó	postgres	{"sesion_nuevo": "activo", "sesion_anterior": "sancionado"}	2
46	2020-11-30 16:33:02.650142	UPDATE	delux	cliente	sifuncionó	postgres	{"sesion_nuevo": "sancionado", "sesion_anterior": "activo"}	2
47	2020-11-30 16:36:23.735476	UPDATE	delux	cliente	sifuncionó	postgres	{"sesion_nuevo": "activo", "sesion_anterior": "sancionado"}	2
\.


                                                                                                               2986.dat                                                                                            0000600 0004000 0002000 00000033766 13761310104 0014275 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	2020-10-12 18:44:27.219886	DELETE	delux	conductor	sistema	postgres	{"email_anterior": "palejandra@gmail.com", "placa_anterior": "NVT610", "nombre_anterior": "Alejandra", "celular_anterior": "3108869467", "usuario_anterior": "aleja1", "apellido_anterior": "Guzman", "contrasena_anterior": "123", "modificado_anterior": "sistema", "id_conductor_anterior": 1, "fecha_de_nacimiento_anterior": "2001-04-13"}	1
2	2020-10-12 18:47:20.956718	INSERT	delux	conductor	motodeluxe	postgres	{"email_nuevo": "jamesrogelioa82@gmail.com", "placa_nuevo": "NVT610", "nombre_nuevo": "James Rogelio", "celular_nuevo": "3229424107", "usuario_nuevo": "jaroalza", "apellido_nuevo": "Alzate Cardenas", "contrasena_nuevo": "jamesalzate", "modificado_nuevo": "motodeluxe", "id_conductor_nuevo": 6, "fecha_de_nacimiento_nuevo": "1978-11-26"}	6
3	2020-10-12 18:48:19.189251	UPDATE	delux	conductor	motodeluxe	postgres	{"usuario_nuevo": "jaroalza1", "usuario_anterior": "jaroalza"}	6
4	2020-10-21 20:32:50.297345	UPDATE	delux	conductor	sistema	postgres	{}	2
5	2020-10-21 20:32:50.297345	UPDATE	delux	conductor	sistema	postgres	{}	3
6	2020-10-21 20:32:50.297345	UPDATE	delux	conductor	sistema	postgres	{}	4
7	2020-10-21 20:32:50.297345	UPDATE	delux	conductor	motodeluxe	postgres	{}	6
8	2020-10-21 20:34:11.658219	UPDATE	delux	conductor	sistema	postgres	{"nombre_nuevo": "Luz Mery", "nombre_anterior": "Luz"}	3
9	2020-10-21 20:34:31.066788	UPDATE	delux	conductor	sistema	postgres	{"sesion_nuevo": "inactivo", "sesion_anterior": "activo"}	3
10	2020-10-22 14:32:53.086616	UPDATE	delux	conductor	sistema	postgres	{}	2
11	2020-10-22 14:32:53.086616	UPDATE	delux	conductor	sistema	postgres	{}	3
12	2020-10-22 14:32:53.086616	UPDATE	delux	conductor	sistema	postgres	{}	4
13	2020-10-22 14:32:53.086616	UPDATE	delux	conductor	motodeluxe	postgres	{}	6
14	2020-10-22 14:42:31.026827	INSERT	delux	conductor	motodeluxe	postgres	{"email_nuevo": "ivanalexanderpreciado0702@gmail.com", "placa_nuevo": "JYA702", "nombre_nuevo": "Ivan Alexander", "sesion_nuevo": "activo", "celular_nuevo": "3108869467", "usuario_nuevo": "ivan", "apellido_nuevo": "Preciado Horta", "id_estado_nuevo": 3, "contrasena_nuevo": "1234", "modificado_nuevo": "motodeluxe", "id_conductor_nuevo": 7, "fecha_de_nacimiento_nuevo": "1999-11-09"}	7
15	2020-10-22 16:18:41.347916	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
16	2020-10-22 16:20:05.401251	UPDATE	delux	conductor	sistema	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 3}	4
17	2020-10-22 16:32:36.334289	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
18	2020-10-22 17:23:36.180635	UPDATE	delux	conductor	sistema	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	4
19	2020-10-22 17:33:04.565949	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
20	2020-10-22 17:33:07.404802	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
21	2020-10-22 17:33:09.959119	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 3}	7
22	2020-10-22 17:33:12.260635	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
23	2020-10-22 17:36:53.213213	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
24	2020-10-22 17:36:55.731849	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
25	2020-10-22 17:36:58.443972	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
26	2020-10-22 17:43:28.142006	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
27	2020-10-22 17:43:33.26439	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
28	2020-10-22 17:50:18.750661	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
29	2020-10-22 17:50:24.426845	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
30	2020-10-22 17:51:09.547693	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
31	2020-10-22 17:51:26.158632	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
32	2020-10-22 17:54:16.509474	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
33	2020-10-22 17:54:18.890577	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
34	2020-10-22 17:54:22.640141	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
35	2020-10-22 17:56:09.41331	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
36	2020-10-22 17:56:11.640979	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
37	2020-10-22 17:56:14.163189	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
38	2020-10-22 17:57:46.852103	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
39	2020-10-22 17:57:52.731305	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
40	2020-10-22 17:57:57.661784	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
41	2020-10-22 17:58:10.352286	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
42	2020-10-22 17:59:47.565689	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
43	2020-10-22 18:04:02.026069	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
44	2020-10-22 18:04:05.894234	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
45	2020-10-22 18:04:09.720397	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
46	2020-10-22 18:04:40.619914	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
47	2020-10-22 18:04:44.527103	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
104	2020-11-20 23:29:43.823676	UPDATE	delux	conductor	motodeluxe	postgres	{}	7
48	2020-10-22 18:04:46.786529	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
49	2020-10-22 18:34:34.546343	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
50	2020-10-22 18:34:50.065097	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
51	2020-10-22 18:36:04.086089	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
52	2020-10-22 18:36:07.801951	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
53	2020-10-22 18:36:44.941145	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
54	2020-10-22 18:36:53.014588	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
55	2020-10-22 18:36:56.453907	UPDATE	delux	conductor	motodeluxe	postgres	{}	7
56	2020-10-22 18:37:46.485487	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
57	2020-10-22 18:37:49.53076	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
58	2020-10-22 18:37:52.787663	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
59	2020-10-22 18:39:04.338453	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
60	2020-10-22 18:39:07.71237	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
61	2020-10-22 18:39:11.052801	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
62	2020-10-22 18:40:24.229188	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
63	2020-10-22 18:40:26.87757	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
64	2020-10-22 18:40:29.224852	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 2}	7
65	2020-10-22 18:43:24.405632	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
66	2020-10-22 18:44:11.890004	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
67	2020-10-23 11:53:53.506707	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
68	2020-10-23 12:14:34.365243	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
69	2020-10-26 12:14:52.066541	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
70	2020-10-26 12:15:13.920125	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
71	2020-10-26 13:14:50.697162	UPDATE	delux	conductor	sistema	postgres	{}	2
72	2020-10-26 15:57:34.411276	UPDATE	delux	conductor	sistema	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	2
73	2020-10-27 15:39:11.924672	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	6
74	2020-10-27 15:39:11.924672	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
75	2020-10-28 18:30:07.341338	UPDATE	delux	conductor	sistema	postgres	{"cedula_nuevo": "1007303580", "cedula_anterior": "1234567890"}	4
76	2020-10-28 18:30:07.341338	UPDATE	delux	conductor	motodeluxe	postgres	{"cedula_nuevo": "1070990186", "cedula_anterior": "1234567890"}	7
77	2020-10-28 18:31:27.361243	UPDATE	delux	conductor	sistema	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	2
78	2020-10-28 18:34:18.117165	INSERT	delux	conductor	motodeluxe	postgres	{"email_nuevo": "mariocruz@gmail.com", "placa_nuevo": "MNJI98", "cedula_nuevo": "107099088", "nombre_nuevo": "Mario", "sesion_nuevo": "activo", "celular_nuevo": "3165678222", "usuario_nuevo": "mario", "apellido_nuevo": "Cruz", "id_estado_nuevo": 3, "contrasena_nuevo": "2108", "modificado_nuevo": "motodeluxe", "id_conductor_nuevo": 8, "fecha_de_nacimiento_nuevo": "2000-08-21"}	8
79	2020-10-28 18:35:46.053213	UPDATE	delux	conductor	motodeluxe	postgres	{"placa_nuevo": "MNJI92", "placa_anterior": "MNJI98"}	8
80	2020-10-29 17:57:09.490366	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
81	2020-10-30 16:08:41.691479	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
82	2020-10-30 17:04:22.319259	UPDATE	delux	conductor	sistema	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 2}	2
83	2020-11-10 17:44:37.332931	UPDATE	delux	conductor	sistema	postgres	{}	2
84	2020-11-10 17:44:37.332931	UPDATE	delux	conductor	sistema	postgres	{}	3
85	2020-11-10 17:44:37.332931	UPDATE	delux	conductor	sistema	postgres	{}	4
86	2020-11-10 17:44:37.332931	UPDATE	delux	conductor	motodeluxe	postgres	{}	6
87	2020-11-10 17:44:37.332931	UPDATE	delux	conductor	motodeluxe	postgres	{}	7
88	2020-11-10 17:44:37.332931	UPDATE	delux	conductor	motodeluxe	postgres	{}	8
89	2020-11-12 12:21:54.363621	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
90	2020-11-12 12:22:00.127219	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 2}	7
91	2020-11-12 12:22:02.855795	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 3, "id_estado_anterior": 1}	7
92	2020-11-12 12:22:07.238434	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 3}	7
93	2020-11-12 12:32:17.633348	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 2, "id_estado_anterior": 1}	7
94	2020-11-12 12:32:20.651416	UPDATE	delux	conductor	motodeluxe	postgres	{"id_estado_nuevo": 1, "id_estado_anterior": 2}	7
95	2020-11-20 15:08:58.294435	UPDATE	delux	conductor	motodeluxe	postgres	{"sesion_nuevo": "sancionado", "sesion_anterior": "activo"}	7
96	2020-11-20 15:09:03.803374	UPDATE	delux	conductor	motodeluxe	postgres	{"fecha_sancion_nuevo": "2020-11-20T15:09:03.782514-05:00", "fecha_sancion_anterior": "2020-11-20T15:08:57.739636-05:00"}	7
97	2020-11-20 15:29:54.900746	UPDATE	delux	conductor	motodeluxe	postgres	{"sesion_nuevo": "espera", "sesion_anterior": "activo"}	8
98	2020-11-20 21:44:31.975489	UPDATE	delux	conductor	motodeluxe	postgres	{"sesion_nuevo": "activo", "sesion_anterior": "sancionado"}	7
99	2020-11-20 21:52:22.473568	UPDATE	delux	conductor	motodeluxe	postgres	{"nombre_nuevo": "Alexander", "apellido_nuevo": "Preciado", "nombre_anterior": "Ivan Alexander", "apellido_anterior": "Preciado Horta"}	7
100	2020-11-20 21:52:32.937081	UPDATE	delux	conductor	motodeluxe	postgres	{"nombre_nuevo": "Ivan Alexander", "apellido_nuevo": "Preciado Horta", "nombre_anterior": "Alexander", "apellido_anterior": "Preciado"}	7
101	2020-11-20 21:52:43.152502	UPDATE	delux	conductor	motodeluxe	postgres	{}	7
102	2020-11-20 21:52:53.408795	UPDATE	delux	conductor	motodeluxe	postgres	{}	7
103	2020-11-20 21:52:57.833464	UPDATE	delux	conductor	motodeluxe	postgres	{}	7
105	2020-11-24 08:38:04.500902	UPDATE	delux	conductor	sistema	postgres	{"sesion_nuevo": "sancionado", "sesion_anterior": "inactivo"}	3
106	2020-11-30 16:10:35.643173	INSERT	delux	conductor	motodeluxe	postgres	{"email_nuevo": "james.alzate22@gmail.com", "placa_nuevo": "ABD78", "cedula_nuevo": "1005879462", "nombre_nuevo": "Juanito", "sesion_nuevo": "espera", "celular_nuevo": "3104587945", "usuario_nuevo": "juanito", "apellido_nuevo": "Perez", "id_estado_nuevo": 3, "contrasena_nuevo": "juanito123", "modificado_nuevo": "motodeluxe", "id_conductor_nuevo": 9, "fecha_sancion_nuevo": null, "fecha_de_nacimiento_nuevo": "1980-05-02"}	9
107	2020-11-30 16:12:22.998297	UPDATE	delux	conductor	motodeluxe	postgres	{"sesion_nuevo": "activo", "sesion_anterior": "espera"}	9
108	2020-11-30 16:23:53.801415	UPDATE	delux	conductor	motodeluxe	postgres	{"sesion_nuevo": "activo", "sesion_anterior": "espera"}	8
\.


          2988.dat                                                                                            0000600 0004000 0002000 00000002732 13761310104 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	2	29f5f21f218e81bc653e1bd3d77afe62a2e7d5e7a57c6033461573fe60815273	\N	\N
2	1	6b2119dd541ed291072ac0fcc646ea217e6670ad61a67fbd47c272154c7ccd73	\N	\N
3	2	cd93e30ed8ae29a3966825a80e75304fbeae1935cb2615e08ce7ace7a63c4ecd	\N	\N
4	3	0f908256744a6316468029f56948ec15e45d0b3690e14247fb20e71692ba2424	\N	\N
5	3	e0f8d95256b8286a76e009e1182ac03a9c37ce393409ed995e080b80a30dcdd4	\N	\N
6	3	b190480e963367d1ee3053fc3d940890c7865f419a0dfc5482394ab203cfd573	\N	\N
7	3	d7b53e95de2adb48e1ca1a1fb09ffcf7965769a69197e695b33600cf396ddae3	\N	\N
8	3	2e3a5b8d6e99e24694d36c197ffd596359c76c952c32e45db976801f6123f213	\N	\N
9	2	9368e38431efbfb5c6cd8139cf42e5d3888a470c02e78665afed4ec21c6d01a2	\N	\N
10	2	d308621f38914cb2a7ad38291da4fc3885262ee2eed9a03751ef4cdb9d47be22	\N	\N
11	3	037e54158eeceede0144915022f5ae227c7acded7cd718ea0e2477bbcc5ee1cc	2020-10-11 18:10:14.994583	2020-10-11 20:10:14.994583
12	4	98b375192b7925a35295d3953a0c165b53346dfe40e17a763ae277a2b8692861	2020-10-11 18:13:34.155849	2020-10-11 20:13:34.155849
13	2	62759d3365310e1573c06d5351a7bbdf3a17b80ee92effe44afa6fbd97c060ee	2020-10-11 18:16:40.896023	2020-10-11 20:16:40.896023
14	1	7a0c26b3abe4d4957012f39d8b111525907dceb400fcc3fbe4a3fff1d082d4be	2020-10-12 15:08:04.24824	2020-10-12 17:08:04.24824
15	1	b006ebb8b95ac3f1a1c996bba9776085331ad8bc656d71995c9f341a4f530a04	2020-10-12 15:24:02.475832	2020-10-12 17:24:02.475832
16	1	0f3ed2d889964d8a51336d2be68e33b3d22f58af8b5f6c559ae95cc591b7de01	2020-11-29 20:15:57.457464	2020-11-29 22:15:57.457464
\.


                                      2989.dat                                                                                            0000600 0004000 0002000 00000002214 13761310104 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        1	1	6dc7631b0c2b0a621b7713b2b121eb9e7ff518b5307b907df0dd4f58a63b7403	2020-10-11 20:03:24.531849-05	2020-10-11 22:03:24.531849-05
2	1	8ff53d9ab33aea0a375202ba044cf8eddaa6bc9122f80ae7d5f01a2cd3935312	2020-10-11 20:04:43.692167-05	2020-10-11 22:04:43.692167-05
3	2	ce57a472e1c73c97fedfa1e5032d84f49646f513c330a04087043a0e0c977b4d	2020-10-11 20:05:45.349213-05	2020-10-11 22:05:45.349213-05
4	3	6da101f97a640383cd6c08b49048af9c0f60ebbd44c55e619b4c49bccfa69dce	2020-10-11 20:17:42.575884-05	2020-10-11 22:17:42.575884-05
5	3	b34772fe4034d22c54e286185eaab8fd13cb0842ddc8e9c342b4c5a79712632e	2020-10-11 20:20:28.663609-05	2020-10-11 22:20:28.663609-05
6	4	d0f5e11a77d5e344b27b6ce45e5f6e4119b7c6f2187bb433a03261c679eee7c1	2020-10-12 15:16:20.022666-05	2020-10-12 17:16:20.022666-05
7	4	1a2b99f1e3b5eba499ceb1b9180b9296132018798c6d06ea951a98fd9c930237	2020-10-12 15:21:32.988393-05	2020-10-12 17:21:32.988393-05
8	7	1b64ad89c8e34eeff25090fc7423fe76d7c9e23b05e4ab0f3897256e3813eadf	2020-11-29 20:34:36.251251-05	2020-11-29 22:34:36.252462-05
9	7	b52c45483a888310c27e0114ab5acdd7c614ae8b7a40e2aa9b7a73c8b57f288e	2020-11-29 20:35:08.83875-05	2020-11-29 22:35:08.83875-05
\.


                                                                                                                                                                                                                                                                                                                                                                                    restore.sql                                                                                         0000600 0004000 0002000 00000163646 13761310104 0015400 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 12.4

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

DROP DATABASE delux;
--
-- Name: delux; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE delux WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Colombia.1252' LC_CTYPE = 'Spanish_Colombia.1252';


ALTER DATABASE delux OWNER TO postgres;

\connect delux

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
-- Name: delux; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA delux;


ALTER SCHEMA delux OWNER TO postgres;

--
-- Name: seguridad; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seguridad;


ALTER SCHEMA seguridad OWNER TO postgres;

--
-- Name: f_log_auditoriacl(); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION seguridad.f_log_auditoriacl() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
		_pk TEXT :='';		-- Representa la llave primaria de la tabla que esta siedno modificada.
		_sql TEXT;		-- Variable para la creacion del procedured.
		_column_guia RECORD; 	-- Variable para el FOR guarda los nombre de las columnas.
		_column_key RECORD; 	-- Variable para el FOR guarda los PK de las columnas.
		_session TEXT;	-- Almacena el usuario que genera el cambio.
		_user_db TEXT;		-- Almacena el usuario de bd que genera la transaccion.
		_control INT;		-- Variabel de control par alas llaves primarias.
		_count_key INT = 0;	-- Cantidad de columnas pertenecientes al PK.
		_sql_insert TEXT;	-- Variable para la construcción del insert del json de forma dinamica.
		_sql_delete TEXT;	-- Variable para la construcción del delete del json de forma dinamica.
		_sql_update TEXT;	-- Variable para la construcción del update del json de forma dinamica.
		_new_data RECORD; 	-- Fila que representa los campos nuevos del registro.
		_old_data RECORD;	-- Fila que representa los campos viejos del registro.

	BEGIN

			-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		 IF (TG_OP = 'INSERT') THEN
			_new_data := NEW;
			_old_data := NEW;
		ELSEIF (TG_OP = 'UPDATE') THEN
			_new_data := NEW;
			_old_data := OLD;
		ELSE
			_new_data := OLD;
			_old_data := OLD;
		END IF;

		-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'id_cliente' ) > 0) THEN
			_pk := _new_data.id_cliente;
		ELSE
			_pk := '-1';
		END IF;

		-- Se valida que exista el campo modified_by
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'modificado') > 0) THEN
			_session := _new_data.modificado;
		ELSE
			_session := '';
		END IF;

		-- Se guarda el susuario de bd que genera la transaccion
		_user_db := (SELECT CURRENT_USER);

		-- Se evalua que exista el procedimeinto adecuado
		IF (SELECT COUNT(*) FROM seguridad.function_db_view acfdv WHERE acfdv.b_function = 'field_audit' AND acfdv.b_type_parameters = TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', character varying, character varying, character varying, text, character varying, text, text') > 0
			THEN
				-- Se realiza la invocación del procedured generado dinamivamente
				PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP, _session, _user_db , _pk, ''::text);
		ELSE
			-- Se empieza la construcción del Procedured generico
			_sql := 'CREATE OR REPLACE FUNCTION seguridad.field_audit( _data_new '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _data_old '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _accion character varying, _session text, _user_db character varying, _table_pk text, _init text)'
			|| ' RETURNS TEXT AS ''
'
			|| '
'
	|| '	DECLARE
'
	|| '		_column_data TEXT;
	 	_datos jsonb;
	 	
'
	|| '	BEGIN
			_datos = ''''{}'''';
';
			-- Se evalua si hay que actualizar la pk del registro de auditoria.
			IF _pk = '-1'
				THEN
					_sql := _sql
					|| '
		_column_data := ';

					-- Se genera el update con la clave pk de la tabla
					SELECT
						COUNT(isk.column_name)
					INTO
						_control
					FROM
						information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
					WHERE
						istc.table_schema = TG_TABLE_SCHEMA
					 AND	istc.table_name = TG_TABLE_NAME
					 AND	istc.constraint_type ilike '%primary%';

					-- Se agregan las columnas que componen la pk de la tabla.
					FOR _column_key IN SELECT
							isk.column_name
						FROM
							information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
						WHERE
							istc.table_schema = TG_TABLE_SCHEMA
						 AND	istc.table_name = TG_TABLE_NAME
						 AND	istc.constraint_type ilike '%primary%'
						ORDER BY 
							isk.ordinal_position  LOOP

						_sql := _sql || ' _data_new.' || _column_key.column_name;
						
						_count_key := _count_key + 1 ;
						
						IF _count_key < _control THEN
							_sql :=	_sql || ' || ' || ''''',''''' || ' ||';
						END IF;
					END LOOP;
				_sql := _sql || ';';
			END IF;

			_sql_insert:='
		IF _accion = ''''INSERT''''
			THEN
				';
			_sql_delete:='
		ELSEIF _accion = ''''DELETE''''
			THEN
				';
			_sql_update:='
		ELSE
			';

			-- Se genera el ciclo de agregado de columnas para el nuevo procedured
			FOR _column_guia IN SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME
				LOOP
						
					_sql_insert:= _sql_insert || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', '
					|| '_data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_insert:= _sql_insert
						||'::text';
					END IF;

					_sql_insert:= _sql_insert || ')::jsonb;
				';

					_sql_delete := _sql_delete || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_delete:= _sql_delete
						||'::text';
					END IF;

					_sql_delete:= _sql_delete || ')::jsonb;
				';

					_sql_update := _sql_update || 'IF _data_old.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || ' <> _data_new.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || '
				THEN _datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ', '''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', _data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ')::jsonb;
			END IF;
			';
			END LOOP;

			-- Se le agrega la parte final del procedured generico
			
			_sql:= _sql || _sql_insert || _sql_delete || _sql_update
			|| ' 
		END IF;

		INSERT INTO seguridad.auditoriacl
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			''''' || TG_TABLE_SCHEMA || ''''',
			''''' || TG_TABLE_NAME || ''''',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;'''
|| '
LANGUAGE plpgsql;';

			-- Se genera la ejecución de _sql, es decir se crea el nuevo procedured de forma generica.
			EXECUTE _sql;

		-- Se realiza la invocación del procedured generado dinamivamente
			PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP::character varying, _session, _user_db, _pk, ''::text);

		END IF;

		RETURN NULL;

END;
$$;


ALTER FUNCTION seguridad.f_log_auditoriacl() OWNER TO postgres;

--
-- Name: f_log_auditoriaco(); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION seguridad.f_log_auditoriaco() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
		_pk TEXT :='';		-- Representa la llave primaria de la tabla que esta siedno modificada.
		_sql TEXT;		-- Variable para la creacion del procedured.
		_column_guia RECORD; 	-- Variable para el FOR guarda los nombre de las columnas.
		_column_key RECORD; 	-- Variable para el FOR guarda los PK de las columnas.
		_session TEXT;	-- Almacena el usuario que genera el cambio.
		_user_db TEXT;		-- Almacena el usuario de bd que genera la transaccion.
		_control INT;		-- Variabel de control par alas llaves primarias.
		_count_key INT = 0;	-- Cantidad de columnas pertenecientes al PK.
		_sql_insert TEXT;	-- Variable para la construcción del insert del json de forma dinamica.
		_sql_delete TEXT;	-- Variable para la construcción del delete del json de forma dinamica.
		_sql_update TEXT;	-- Variable para la construcción del update del json de forma dinamica.
		_new_data RECORD; 	-- Fila que representa los campos nuevos del registro.
		_old_data RECORD;	-- Fila que representa los campos viejos del registro.

	BEGIN

			-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		 IF (TG_OP = 'INSERT') THEN
			_new_data := NEW;
			_old_data := NEW;
		ELSEIF (TG_OP = 'UPDATE') THEN
			_new_data := NEW;
			_old_data := OLD;
		ELSE
			_new_data := OLD;
			_old_data := OLD;
		END IF;

		-- Se genera la evaluacion para determianr el tipo de accion sobre la tabla
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'id_conductor' ) > 0) THEN
			_pk := _new_data.id_conductor;
		ELSE
			_pk := '-1';
		END IF;

		-- Se valida que exista el campo modified_by
		IF ((SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME AND column_name = 'modificado') > 0) THEN
			_session := _new_data.modificado;
		ELSE
			_session := '';
		END IF;

		-- Se guarda el susuario de bd que genera la transaccion
		_user_db := (SELECT CURRENT_USER);

		-- Se evalua que exista el procedimeinto adecuado
		IF (SELECT COUNT(*) FROM seguridad.function_db_view acfdv WHERE acfdv.b_function = 'field_audit' AND acfdv.b_type_parameters = TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', character varying, character varying, character varying, text, character varying, text, text') > 0
			THEN
				-- Se realiza la invocación del procedured generado dinamivamente
				PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP, _session, _user_db , _pk, ''::text);
		ELSE
			-- Se empieza la construcción del Procedured generico
			_sql := 'CREATE OR REPLACE FUNCTION seguridad.field_audit( _data_new '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _data_old '|| TG_TABLE_SCHEMA || '.'|| TG_TABLE_NAME || ', _accion character varying, _session text, _user_db character varying, _table_pk text, _init text)'
			|| ' RETURNS TEXT AS ''
'
			|| '
'
	|| '	DECLARE
'
	|| '		_column_data TEXT;
	 	_datos jsonb;
	 	
'
	|| '	BEGIN
			_datos = ''''{}'''';
';
			-- Se evalua si hay que actualizar la pk del registro de auditoria.
			IF _pk = '-1'
				THEN
					_sql := _sql
					|| '
		_column_data := ';

					-- Se genera el update con la clave pk de la tabla
					SELECT
						COUNT(isk.column_name)
					INTO
						_control
					FROM
						information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
					WHERE
						istc.table_schema = TG_TABLE_SCHEMA
					 AND	istc.table_name = TG_TABLE_NAME
					 AND	istc.constraint_type ilike '%primary%';

					-- Se agregan las columnas que componen la pk de la tabla.
					FOR _column_key IN SELECT
							isk.column_name
						FROM
							information_schema.table_constraints istc JOIN information_schema.key_column_usage isk ON isk.constraint_name = istc.constraint_name
						WHERE
							istc.table_schema = TG_TABLE_SCHEMA
						 AND	istc.table_name = TG_TABLE_NAME
						 AND	istc.constraint_type ilike '%primary%'
						ORDER BY 
							isk.ordinal_position  LOOP

						_sql := _sql || ' _data_new.' || _column_key.column_name;
						
						_count_key := _count_key + 1 ;
						
						IF _count_key < _control THEN
							_sql :=	_sql || ' || ' || ''''',''''' || ' ||';
						END IF;
					END LOOP;
				_sql := _sql || ';';
			END IF;

			_sql_insert:='
		IF _accion = ''''INSERT''''
			THEN
				';
			_sql_delete:='
		ELSEIF _accion = ''''DELETE''''
			THEN
				';
			_sql_update:='
		ELSE
			';

			-- Se genera el ciclo de agregado de columnas para el nuevo procedured
			FOR _column_guia IN SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = TG_TABLE_SCHEMA AND table_name = TG_TABLE_NAME
				LOOP
						
					_sql_insert:= _sql_insert || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', '
					|| '_data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_insert:= _sql_insert
						||'::text';
					END IF;

					_sql_insert:= _sql_insert || ')::jsonb;
				';

					_sql_delete := _sql_delete || '_datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_delete:= _sql_delete
						||'::text';
					END IF;

					_sql_delete:= _sql_delete || ')::jsonb;
				';

					_sql_update := _sql_update || 'IF _data_old.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || ' <> _data_new.' || _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update || '
				THEN _datos := _datos || json_build_object('''''
					|| _column_guia.column_name
					|| '_anterior'
					|| ''''', '
					|| '_data_old.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea','USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ', '''''
					|| _column_guia.column_name
					|| '_nuevo'
					|| ''''', _data_new.'
					|| _column_guia.column_name;

					IF _column_guia.data_type IN ('bytea', 'USER-DEFINED') THEN 
						_sql_update:= _sql_update
						||'::text';
					END IF;

					_sql_update:= _sql_update
					|| ')::jsonb;
			END IF;
			';
			END LOOP;

			-- Se le agrega la parte final del procedured generico
			
			_sql:= _sql || _sql_insert || _sql_delete || _sql_update
			|| ' 
		END IF;

		INSERT INTO seguridad.auditoriaco
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			''''' || TG_TABLE_SCHEMA || ''''',
			''''' || TG_TABLE_NAME || ''''',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;'''
|| '
LANGUAGE plpgsql;';

			-- Se genera la ejecución de _sql, es decir se crea el nuevo procedured de forma generica.
			EXECUTE _sql;

		-- Se realiza la invocación del procedured generado dinamivamente
			PERFORM seguridad.field_audit(_new_data, _old_data, TG_OP::character varying, _session, _user_db, _pk, ''::text);

		END IF;

		RETURN NULL;

END;
$$;


ALTER FUNCTION seguridad.f_log_auditoriaco() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cliente; Type: TABLE; Schema: delux; Owner: postgres
--

CREATE TABLE delux.cliente (
    id_cliente integer NOT NULL,
    nombre text NOT NULL,
    apellido text,
    fecha_de_nacimiento date NOT NULL,
    email text NOT NULL,
    usuario text NOT NULL,
    contrasena text NOT NULL,
    modificado text DEFAULT 'sistema'::text NOT NULL,
    sesion text,
    fecha_sancion timestamp with time zone
);


ALTER TABLE delux.cliente OWNER TO postgres;

--
-- Name: field_audit(delux.cliente, delux.cliente, character varying, text, character varying, text, text); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION seguridad.field_audit(_data_new delux.cliente, _data_old delux.cliente, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text) RETURNS text
    LANGUAGE plpgsql
    AS $$

	DECLARE
		_column_data TEXT;
	 	_datos jsonb;
	 	
	BEGIN
			_datos = '{}';

		IF _accion = 'INSERT'
			THEN
				_datos := _datos || json_build_object('id_cliente_nuevo', _data_new.id_cliente)::jsonb;
				_datos := _datos || json_build_object('nombre_nuevo', _data_new.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_nuevo', _data_new.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_nuevo', _data_new.email)::jsonb;
				_datos := _datos || json_build_object('usuario_nuevo', _data_new.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_nuevo', _data_new.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_nuevo', _data_new.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_nuevo', _data_new.sesion)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
				
		ELSEIF _accion = 'DELETE'
			THEN
				_datos := _datos || json_build_object('id_cliente_anterior', _data_old.id_cliente)::jsonb;
				_datos := _datos || json_build_object('nombre_anterior', _data_old.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_anterior', _data_old.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_anterior', _data_old.email)::jsonb;
				_datos := _datos || json_build_object('usuario_anterior', _data_old.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_anterior', _data_old.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_anterior', _data_old.sesion)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion)::jsonb;
				
		ELSE
			IF _data_old.id_cliente <> _data_new.id_cliente
				THEN _datos := _datos || json_build_object('id_cliente_anterior', _data_old.id_cliente, 'id_cliente_nuevo', _data_new.id_cliente)::jsonb;
			END IF;
			IF _data_old.nombre <> _data_new.nombre
				THEN _datos := _datos || json_build_object('nombre_anterior', _data_old.nombre, 'nombre_nuevo', _data_new.nombre)::jsonb;
			END IF;
			IF _data_old.apellido <> _data_new.apellido
				THEN _datos := _datos || json_build_object('apellido_anterior', _data_old.apellido, 'apellido_nuevo', _data_new.apellido)::jsonb;
			END IF;
			IF _data_old.fecha_de_nacimiento <> _data_new.fecha_de_nacimiento
				THEN _datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento, 'fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
			END IF;
			IF _data_old.email <> _data_new.email
				THEN _datos := _datos || json_build_object('email_anterior', _data_old.email, 'email_nuevo', _data_new.email)::jsonb;
			END IF;
			IF _data_old.usuario <> _data_new.usuario
				THEN _datos := _datos || json_build_object('usuario_anterior', _data_old.usuario, 'usuario_nuevo', _data_new.usuario)::jsonb;
			END IF;
			IF _data_old.contrasena <> _data_new.contrasena
				THEN _datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena, 'contrasena_nuevo', _data_new.contrasena)::jsonb;
			END IF;
			IF _data_old.modificado <> _data_new.modificado
				THEN _datos := _datos || json_build_object('modificado_anterior', _data_old.modificado, 'modificado_nuevo', _data_new.modificado)::jsonb;
			END IF;
			IF _data_old.sesion <> _data_new.sesion
				THEN _datos := _datos || json_build_object('sesion_anterior', _data_old.sesion, 'sesion_nuevo', _data_new.sesion)::jsonb;
			END IF;
			IF _data_old.fecha_sancion <> _data_new.fecha_sancion
				THEN _datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion, 'fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
			END IF;
			 
		END IF;

		INSERT INTO seguridad.auditoriacl
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			'delux',
			'cliente',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;$$;


ALTER FUNCTION seguridad.field_audit(_data_new delux.cliente, _data_old delux.cliente, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text) OWNER TO postgres;

--
-- Name: conductor; Type: TABLE; Schema: delux; Owner: postgres
--

CREATE TABLE delux.conductor (
    id_conductor integer NOT NULL,
    nombre text NOT NULL,
    apellido text,
    fecha_de_nacimiento date NOT NULL,
    email text NOT NULL,
    placa text NOT NULL,
    celular text NOT NULL,
    usuario text NOT NULL,
    contrasena text NOT NULL,
    modificado text DEFAULT 'sistema'::text NOT NULL,
    sesion text,
    id_estado integer NOT NULL,
    cedula text DEFAULT '1234567890'::text NOT NULL,
    fecha_sancion timestamp with time zone
);


ALTER TABLE delux.conductor OWNER TO postgres;

--
-- Name: field_audit(delux.conductor, delux.conductor, character varying, text, character varying, text, text); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION seguridad.field_audit(_data_new delux.conductor, _data_old delux.conductor, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text) RETURNS text
    LANGUAGE plpgsql
    AS $$

	DECLARE
		_column_data TEXT;
	 	_datos jsonb;
	 	
	BEGIN
			_datos = '{}';

		IF _accion = 'INSERT'
			THEN
				_datos := _datos || json_build_object('id_conductor_nuevo', _data_new.id_conductor)::jsonb;
				_datos := _datos || json_build_object('nombre_nuevo', _data_new.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_nuevo', _data_new.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_nuevo', _data_new.email)::jsonb;
				_datos := _datos || json_build_object('placa_nuevo', _data_new.placa)::jsonb;
				_datos := _datos || json_build_object('celular_nuevo', _data_new.celular)::jsonb;
				_datos := _datos || json_build_object('usuario_nuevo', _data_new.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_nuevo', _data_new.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_nuevo', _data_new.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_nuevo', _data_new.sesion)::jsonb;
				_datos := _datos || json_build_object('id_estado_nuevo', _data_new.id_estado)::jsonb;
				_datos := _datos || json_build_object('cedula_nuevo', _data_new.cedula)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
				
		ELSEIF _accion = 'DELETE'
			THEN
				_datos := _datos || json_build_object('id_conductor_anterior', _data_old.id_conductor)::jsonb;
				_datos := _datos || json_build_object('nombre_anterior', _data_old.nombre)::jsonb;
				_datos := _datos || json_build_object('apellido_anterior', _data_old.apellido)::jsonb;
				_datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento)::jsonb;
				_datos := _datos || json_build_object('email_anterior', _data_old.email)::jsonb;
				_datos := _datos || json_build_object('placa_anterior', _data_old.placa)::jsonb;
				_datos := _datos || json_build_object('celular_anterior', _data_old.celular)::jsonb;
				_datos := _datos || json_build_object('usuario_anterior', _data_old.usuario)::jsonb;
				_datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena)::jsonb;
				_datos := _datos || json_build_object('modificado_anterior', _data_old.modificado)::jsonb;
				_datos := _datos || json_build_object('sesion_anterior', _data_old.sesion)::jsonb;
				_datos := _datos || json_build_object('id_estado_anterior', _data_old.id_estado)::jsonb;
				_datos := _datos || json_build_object('cedula_anterior', _data_old.cedula)::jsonb;
				_datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion)::jsonb;
				
		ELSE
			IF _data_old.id_conductor <> _data_new.id_conductor
				THEN _datos := _datos || json_build_object('id_conductor_anterior', _data_old.id_conductor, 'id_conductor_nuevo', _data_new.id_conductor)::jsonb;
			END IF;
			IF _data_old.nombre <> _data_new.nombre
				THEN _datos := _datos || json_build_object('nombre_anterior', _data_old.nombre, 'nombre_nuevo', _data_new.nombre)::jsonb;
			END IF;
			IF _data_old.apellido <> _data_new.apellido
				THEN _datos := _datos || json_build_object('apellido_anterior', _data_old.apellido, 'apellido_nuevo', _data_new.apellido)::jsonb;
			END IF;
			IF _data_old.fecha_de_nacimiento <> _data_new.fecha_de_nacimiento
				THEN _datos := _datos || json_build_object('fecha_de_nacimiento_anterior', _data_old.fecha_de_nacimiento, 'fecha_de_nacimiento_nuevo', _data_new.fecha_de_nacimiento)::jsonb;
			END IF;
			IF _data_old.email <> _data_new.email
				THEN _datos := _datos || json_build_object('email_anterior', _data_old.email, 'email_nuevo', _data_new.email)::jsonb;
			END IF;
			IF _data_old.placa <> _data_new.placa
				THEN _datos := _datos || json_build_object('placa_anterior', _data_old.placa, 'placa_nuevo', _data_new.placa)::jsonb;
			END IF;
			IF _data_old.celular <> _data_new.celular
				THEN _datos := _datos || json_build_object('celular_anterior', _data_old.celular, 'celular_nuevo', _data_new.celular)::jsonb;
			END IF;
			IF _data_old.usuario <> _data_new.usuario
				THEN _datos := _datos || json_build_object('usuario_anterior', _data_old.usuario, 'usuario_nuevo', _data_new.usuario)::jsonb;
			END IF;
			IF _data_old.contrasena <> _data_new.contrasena
				THEN _datos := _datos || json_build_object('contrasena_anterior', _data_old.contrasena, 'contrasena_nuevo', _data_new.contrasena)::jsonb;
			END IF;
			IF _data_old.modificado <> _data_new.modificado
				THEN _datos := _datos || json_build_object('modificado_anterior', _data_old.modificado, 'modificado_nuevo', _data_new.modificado)::jsonb;
			END IF;
			IF _data_old.sesion <> _data_new.sesion
				THEN _datos := _datos || json_build_object('sesion_anterior', _data_old.sesion, 'sesion_nuevo', _data_new.sesion)::jsonb;
			END IF;
			IF _data_old.id_estado <> _data_new.id_estado
				THEN _datos := _datos || json_build_object('id_estado_anterior', _data_old.id_estado, 'id_estado_nuevo', _data_new.id_estado)::jsonb;
			END IF;
			IF _data_old.cedula <> _data_new.cedula
				THEN _datos := _datos || json_build_object('cedula_anterior', _data_old.cedula, 'cedula_nuevo', _data_new.cedula)::jsonb;
			END IF;
			IF _data_old.fecha_sancion <> _data_new.fecha_sancion
				THEN _datos := _datos || json_build_object('fecha_sancion_anterior', _data_old.fecha_sancion, 'fecha_sancion_nuevo', _data_new.fecha_sancion)::jsonb;
			END IF;
			 
		END IF;

		INSERT INTO seguridad.auditoriaco
		(
			fecha,
			accion,
			schema,
			tabla,
			pk,
			session,
			user_bd,
			data
		)
		VALUES
		(
			CURRENT_TIMESTAMP,
			_accion,
			'delux',
			'conductor',
			_table_pk,
			_session,
			_user_db,
			_datos::jsonb
			);

		RETURN NULL; 
	END;$$;


ALTER FUNCTION seguridad.field_audit(_data_new delux.conductor, _data_old delux.conductor, _accion character varying, _session text, _user_db character varying, _table_pk text, _init text) OWNER TO postgres;

--
-- Name: administrador; Type: TABLE; Schema: delux; Owner: postgres
--

CREATE TABLE delux.administrador (
    id integer NOT NULL,
    usuario text,
    contrasena text
);


ALTER TABLE delux.administrador OWNER TO postgres;

--
-- Name: administrador_id_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux.administrador_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux.administrador_id_seq OWNER TO postgres;

--
-- Name: administrador_id_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux.administrador_id_seq OWNED BY delux.administrador.id;


--
-- Name: cliente_id_cliente_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux.cliente_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux.cliente_id_cliente_seq OWNER TO postgres;

--
-- Name: cliente_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux.cliente_id_cliente_seq OWNED BY delux.cliente.id_cliente;


--
-- Name: conductor_id_conductor_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux.conductor_id_conductor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux.conductor_id_conductor_seq OWNER TO postgres;

--
-- Name: conductor_id_conductor_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux.conductor_id_conductor_seq OWNED BY delux.conductor.id_conductor;


--
-- Name: destino; Type: TABLE; Schema: delux; Owner: postgres
--

CREATE TABLE delux.destino (
    id integer NOT NULL,
    lugar_destino text NOT NULL,
    lugar_ubicacion text
);


ALTER TABLE delux.destino OWNER TO postgres;

--
-- Name: destino_id_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux.destino_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux.destino_id_seq OWNER TO postgres;

--
-- Name: destino_id_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux.destino_id_seq OWNED BY delux.destino.id;


--
-- Name: estado; Type: TABLE; Schema: delux; Owner: postgres
--

CREATE TABLE delux.estado (
    id integer NOT NULL,
    disponibilidad text
);


ALTER TABLE delux.estado OWNER TO postgres;

--
-- Name: estado_id_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux.estado_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux.estado_id_seq OWNER TO postgres;

--
-- Name: estado_id_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux.estado_id_seq OWNED BY delux.estado.id;


--
-- Name: notificacion_de_servicio; Type: TABLE; Schema: delux; Owner: postgres
--

CREATE TABLE delux.notificacion_de_servicio (
    id_cliente integer NOT NULL,
    id integer NOT NULL,
    id_destino integer NOT NULL,
    id_ubicacion integer NOT NULL,
    descripcion_servicio text,
    tarifa double precision DEFAULT 100 NOT NULL,
    fecha_carrera timestamp with time zone,
    pago integer,
    kilometros double precision,
    estado text,
    conductor text,
    comentario_de_conductor text,
    fecha_fin_carrera timestamp with time zone,
    comentario_de_cliente text,
    id_conductor integer,
    conversacion text
);


ALTER TABLE delux.notificacion_de_servicio OWNER TO postgres;

--
-- Name: notificacion de servicio_id_cliente_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux."notificacion de servicio_id_cliente_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux."notificacion de servicio_id_cliente_seq" OWNER TO postgres;

--
-- Name: notificacion de servicio_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux."notificacion de servicio_id_cliente_seq" OWNED BY delux.notificacion_de_servicio.id_cliente;


--
-- Name: notificacion de servicio_id_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux."notificacion de servicio_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux."notificacion de servicio_id_seq" OWNER TO postgres;

--
-- Name: notificacion de servicio_id_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux."notificacion de servicio_id_seq" OWNED BY delux.notificacion_de_servicio.id;


--
-- Name: pago; Type: TABLE; Schema: delux; Owner: postgres
--

CREATE TABLE delux.pago (
    id integer NOT NULL,
    descripcion text NOT NULL
);


ALTER TABLE delux.pago OWNER TO postgres;

--
-- Name: pago_id_seq; Type: SEQUENCE; Schema: delux; Owner: postgres
--

CREATE SEQUENCE delux.pago_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE delux.pago_id_seq OWNER TO postgres;

--
-- Name: pago_id_seq; Type: SEQUENCE OWNED BY; Schema: delux; Owner: postgres
--

ALTER SEQUENCE delux.pago_id_seq OWNED BY delux.pago.id;


--
-- Name: acceso_cliente; Type: TABLE; Schema: seguridad; Owner: postgres
--

CREATE TABLE seguridad.acceso_cliente (
    id integer NOT NULL,
    id_cliente integer NOT NULL,
    ip text NOT NULL,
    mac text NOT NULL,
    fecha_inicio timestamp without time zone NOT NULL,
    session text NOT NULL,
    fecha_fin text
);


ALTER TABLE seguridad.acceso_cliente OWNER TO postgres;

--
-- Name: acceso_cliente_id_seq; Type: SEQUENCE; Schema: seguridad; Owner: postgres
--

CREATE SEQUENCE seguridad.acceso_cliente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seguridad.acceso_cliente_id_seq OWNER TO postgres;

--
-- Name: acceso_cliente_id_seq; Type: SEQUENCE OWNED BY; Schema: seguridad; Owner: postgres
--

ALTER SEQUENCE seguridad.acceso_cliente_id_seq OWNED BY seguridad.acceso_cliente.id;


--
-- Name: acceso_conductor; Type: TABLE; Schema: seguridad; Owner: postgres
--

CREATE TABLE seguridad.acceso_conductor (
    id integer NOT NULL,
    id_conductor integer NOT NULL,
    ip text NOT NULL,
    mac text NOT NULL,
    fecha_inicio timestamp without time zone NOT NULL,
    session text NOT NULL,
    fecha_fin text
);


ALTER TABLE seguridad.acceso_conductor OWNER TO postgres;

--
-- Name: acceso_conductor_id_seq; Type: SEQUENCE; Schema: seguridad; Owner: postgres
--

CREATE SEQUENCE seguridad.acceso_conductor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seguridad.acceso_conductor_id_seq OWNER TO postgres;

--
-- Name: acceso_conductor_id_seq; Type: SEQUENCE OWNED BY; Schema: seguridad; Owner: postgres
--

ALTER SEQUENCE seguridad.acceso_conductor_id_seq OWNED BY seguridad.acceso_conductor.id;


--
-- Name: auditoriacl; Type: TABLE; Schema: seguridad; Owner: postgres
--

CREATE TABLE seguridad.auditoriacl (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    accion character varying(100),
    schema character varying(200) NOT NULL,
    tabla character varying(200),
    session text NOT NULL,
    user_bd character varying(100) NOT NULL,
    data jsonb NOT NULL,
    pk text NOT NULL
);


ALTER TABLE seguridad.auditoriacl OWNER TO postgres;

--
-- Name: TABLE auditoriacl; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON TABLE seguridad.auditoriacl IS 'Tabla que almacena la trazabilidad de la informaicón.';


--
-- Name: COLUMN auditoriacl.id; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.id IS 'campo pk de la tabla ';


--
-- Name: COLUMN auditoriacl.fecha; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.fecha IS 'ALmacen ala la fecha de la modificación';


--
-- Name: COLUMN auditoriacl.accion; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.accion IS 'Almacena la accion que se ejecuto sobre el registro';


--
-- Name: COLUMN auditoriacl.schema; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.schema IS 'Almanena el nomnbre del schema de la tabla que se modifico';


--
-- Name: COLUMN auditoriacl.tabla; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.tabla IS 'Almacena el nombre de la tabla que se modifico';


--
-- Name: COLUMN auditoriacl.session; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.session IS 'Campo que almacena el id de la session que generó el cambio';


--
-- Name: COLUMN auditoriacl.user_bd; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.user_bd IS 'Campo que almacena el user que se autentico en el motor para generar el cmabio';


--
-- Name: COLUMN auditoriacl.data; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.data IS 'campo que almacena la modificaicón que se realizó';


--
-- Name: COLUMN auditoriacl.pk; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriacl.pk IS 'Campo que identifica el id del registro.';


--
-- Name: auditoriacl_id_seq; Type: SEQUENCE; Schema: seguridad; Owner: postgres
--

CREATE SEQUENCE seguridad.auditoriacl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seguridad.auditoriacl_id_seq OWNER TO postgres;

--
-- Name: auditoriacl_id_seq; Type: SEQUENCE OWNED BY; Schema: seguridad; Owner: postgres
--

ALTER SEQUENCE seguridad.auditoriacl_id_seq OWNED BY seguridad.auditoriacl.id;


--
-- Name: auditoriaco; Type: TABLE; Schema: seguridad; Owner: postgres
--

CREATE TABLE seguridad.auditoriaco (
    id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    accion character varying(100),
    schema character varying(200) NOT NULL,
    tabla character varying(200),
    session text NOT NULL,
    user_bd character varying(100) NOT NULL,
    data jsonb NOT NULL,
    pk text NOT NULL
);


ALTER TABLE seguridad.auditoriaco OWNER TO postgres;

--
-- Name: TABLE auditoriaco; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON TABLE seguridad.auditoriaco IS 'Tabla que almacena la trazabilidad de la informaicón.';


--
-- Name: COLUMN auditoriaco.id; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.id IS 'campo pk de la tabla ';


--
-- Name: COLUMN auditoriaco.fecha; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.fecha IS 'ALmacen ala la fecha de la modificación';


--
-- Name: COLUMN auditoriaco.accion; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.accion IS 'Almacena la accion que se ejecuto sobre el registro';


--
-- Name: COLUMN auditoriaco.schema; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.schema IS 'Almanena el nomnbre del schema de la tabla que se modifico';


--
-- Name: COLUMN auditoriaco.tabla; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.tabla IS 'Almacena el nombre de la tabla que se modifico';


--
-- Name: COLUMN auditoriaco.session; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.session IS 'Campo que almacena el id de la session que generó el cambio';


--
-- Name: COLUMN auditoriaco.user_bd; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.user_bd IS 'Campo que almacena el user que se autentico en el motor para generar el cmabio';


--
-- Name: COLUMN auditoriaco.data; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.data IS 'campo que almacena la modificaicón que se realizó';


--
-- Name: COLUMN auditoriaco.pk; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN seguridad.auditoriaco.pk IS 'Campo que identifica el id del registro.';


--
-- Name: auditoriaco_id_seq; Type: SEQUENCE; Schema: seguridad; Owner: postgres
--

CREATE SEQUENCE seguridad.auditoriaco_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seguridad.auditoriaco_id_seq OWNER TO postgres;

--
-- Name: auditoriaco_id_seq; Type: SEQUENCE OWNED BY; Schema: seguridad; Owner: postgres
--

ALTER SEQUENCE seguridad.auditoriaco_id_seq OWNED BY seguridad.auditoriaco.id;


--
-- Name: function_db_view; Type: VIEW; Schema: seguridad; Owner: postgres
--

CREATE VIEW seguridad.function_db_view AS
 SELECT pp.proname AS b_function,
    oidvectortypes(pp.proargtypes) AS b_type_parameters
   FROM (pg_proc pp
     JOIN pg_namespace pn ON ((pn.oid = pp.pronamespace)))
  WHERE ((pn.nspname)::text <> ALL (ARRAY[('pg_catalog'::character varying)::text, ('information_schema'::character varying)::text, ('admin_control'::character varying)::text, ('vial'::character varying)::text]));


ALTER TABLE seguridad.function_db_view OWNER TO postgres;

--
-- Name: token_recuperacion; Type: TABLE; Schema: seguridad; Owner: postgres
--

CREATE TABLE seguridad.token_recuperacion (
    id integer NOT NULL,
    id_cliente integer NOT NULL,
    token text NOT NULL,
    creado timestamp without time zone,
    vigencia timestamp without time zone
);


ALTER TABLE seguridad.token_recuperacion OWNER TO postgres;

--
-- Name: token_recuperacion_conductor; Type: TABLE; Schema: seguridad; Owner: postgres
--

CREATE TABLE seguridad.token_recuperacion_conductor (
    id integer NOT NULL,
    id_conductor integer NOT NULL,
    token text NOT NULL,
    creado timestamp with time zone NOT NULL,
    vigencia timestamp with time zone NOT NULL
);


ALTER TABLE seguridad.token_recuperacion_conductor OWNER TO postgres;

--
-- Name: token_recuperacion_conductor_id_seq; Type: SEQUENCE; Schema: seguridad; Owner: postgres
--

CREATE SEQUENCE seguridad.token_recuperacion_conductor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seguridad.token_recuperacion_conductor_id_seq OWNER TO postgres;

--
-- Name: token_recuperacion_conductor_id_seq; Type: SEQUENCE OWNED BY; Schema: seguridad; Owner: postgres
--

ALTER SEQUENCE seguridad.token_recuperacion_conductor_id_seq OWNED BY seguridad.token_recuperacion_conductor.id;


--
-- Name: token_recuperacion_id_seq; Type: SEQUENCE; Schema: seguridad; Owner: postgres
--

CREATE SEQUENCE seguridad.token_recuperacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE seguridad.token_recuperacion_id_seq OWNER TO postgres;

--
-- Name: token_recuperacion_id_seq; Type: SEQUENCE OWNED BY; Schema: seguridad; Owner: postgres
--

ALTER SEQUENCE seguridad.token_recuperacion_id_seq OWNED BY seguridad.token_recuperacion.id;


--
-- Name: administrador id; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.administrador ALTER COLUMN id SET DEFAULT nextval('delux.administrador_id_seq'::regclass);


--
-- Name: cliente id_cliente; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.cliente ALTER COLUMN id_cliente SET DEFAULT nextval('delux.cliente_id_cliente_seq'::regclass);


--
-- Name: conductor id_conductor; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.conductor ALTER COLUMN id_conductor SET DEFAULT nextval('delux.conductor_id_conductor_seq'::regclass);


--
-- Name: destino id; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.destino ALTER COLUMN id SET DEFAULT nextval('delux.destino_id_seq'::regclass);


--
-- Name: estado id; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.estado ALTER COLUMN id SET DEFAULT nextval('delux.estado_id_seq'::regclass);


--
-- Name: notificacion_de_servicio id_cliente; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.notificacion_de_servicio ALTER COLUMN id_cliente SET DEFAULT nextval('delux."notificacion de servicio_id_cliente_seq"'::regclass);


--
-- Name: notificacion_de_servicio id; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.notificacion_de_servicio ALTER COLUMN id SET DEFAULT nextval('delux."notificacion de servicio_id_seq"'::regclass);


--
-- Name: pago id; Type: DEFAULT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.pago ALTER COLUMN id SET DEFAULT nextval('delux.pago_id_seq'::regclass);


--
-- Name: acceso_cliente id; Type: DEFAULT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.acceso_cliente ALTER COLUMN id SET DEFAULT nextval('seguridad.acceso_cliente_id_seq'::regclass);


--
-- Name: acceso_conductor id; Type: DEFAULT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.acceso_conductor ALTER COLUMN id SET DEFAULT nextval('seguridad.acceso_conductor_id_seq'::regclass);


--
-- Name: auditoriacl id; Type: DEFAULT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.auditoriacl ALTER COLUMN id SET DEFAULT nextval('seguridad.auditoriacl_id_seq'::regclass);


--
-- Name: auditoriaco id; Type: DEFAULT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.auditoriaco ALTER COLUMN id SET DEFAULT nextval('seguridad.auditoriaco_id_seq'::regclass);


--
-- Name: token_recuperacion id; Type: DEFAULT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.token_recuperacion ALTER COLUMN id SET DEFAULT nextval('seguridad.token_recuperacion_id_seq'::regclass);


--
-- Name: token_recuperacion_conductor id; Type: DEFAULT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.token_recuperacion_conductor ALTER COLUMN id SET DEFAULT nextval('seguridad.token_recuperacion_conductor_id_seq'::regclass);


--
-- Data for Name: administrador; Type: TABLE DATA; Schema: delux; Owner: postgres
--

COPY delux.administrador (id, usuario, contrasena) FROM stdin;
\.
COPY delux.administrador (id, usuario, contrasena) FROM '$$PATH$$/2967.dat';

--
-- Data for Name: cliente; Type: TABLE DATA; Schema: delux; Owner: postgres
--

COPY delux.cliente (id_cliente, nombre, apellido, fecha_de_nacimiento, email, usuario, contrasena, modificado, sesion, fecha_sancion) FROM stdin;
\.
COPY delux.cliente (id_cliente, nombre, apellido, fecha_de_nacimiento, email, usuario, contrasena, modificado, sesion, fecha_sancion) FROM '$$PATH$$/2965.dat';

--
-- Data for Name: conductor; Type: TABLE DATA; Schema: delux; Owner: postgres
--

COPY delux.conductor (id_conductor, nombre, apellido, fecha_de_nacimiento, email, placa, celular, usuario, contrasena, modificado, sesion, id_estado, cedula, fecha_sancion) FROM stdin;
\.
COPY delux.conductor (id_conductor, nombre, apellido, fecha_de_nacimiento, email, placa, celular, usuario, contrasena, modificado, sesion, id_estado, cedula, fecha_sancion) FROM '$$PATH$$/2966.dat';

--
-- Data for Name: destino; Type: TABLE DATA; Schema: delux; Owner: postgres
--

COPY delux.destino (id, lugar_destino, lugar_ubicacion) FROM stdin;
\.
COPY delux.destino (id, lugar_destino, lugar_ubicacion) FROM '$$PATH$$/2971.dat';

--
-- Data for Name: estado; Type: TABLE DATA; Schema: delux; Owner: postgres
--

COPY delux.estado (id, disponibilidad) FROM stdin;
\.
COPY delux.estado (id, disponibilidad) FROM '$$PATH$$/2973.dat';

--
-- Data for Name: notificacion_de_servicio; Type: TABLE DATA; Schema: delux; Owner: postgres
--

COPY delux.notificacion_de_servicio (id_cliente, id, id_destino, id_ubicacion, descripcion_servicio, tarifa, fecha_carrera, pago, kilometros, estado, conductor, comentario_de_conductor, fecha_fin_carrera, comentario_de_cliente, id_conductor, conversacion) FROM stdin;
\.
COPY delux.notificacion_de_servicio (id_cliente, id, id_destino, id_ubicacion, descripcion_servicio, tarifa, fecha_carrera, pago, kilometros, estado, conductor, comentario_de_conductor, fecha_fin_carrera, comentario_de_cliente, id_conductor, conversacion) FROM '$$PATH$$/2975.dat';

--
-- Data for Name: pago; Type: TABLE DATA; Schema: delux; Owner: postgres
--

COPY delux.pago (id, descripcion) FROM stdin;
\.
COPY delux.pago (id, descripcion) FROM '$$PATH$$/2978.dat';

--
-- Data for Name: acceso_cliente; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

COPY seguridad.acceso_cliente (id, id_cliente, ip, mac, fecha_inicio, session, fecha_fin) FROM stdin;
\.
COPY seguridad.acceso_cliente (id, id_cliente, ip, mac, fecha_inicio, session, fecha_fin) FROM '$$PATH$$/2980.dat';

--
-- Data for Name: acceso_conductor; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

COPY seguridad.acceso_conductor (id, id_conductor, ip, mac, fecha_inicio, session, fecha_fin) FROM stdin;
\.
COPY seguridad.acceso_conductor (id, id_conductor, ip, mac, fecha_inicio, session, fecha_fin) FROM '$$PATH$$/2982.dat';

--
-- Data for Name: auditoriacl; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

COPY seguridad.auditoriacl (id, fecha, accion, schema, tabla, session, user_bd, data, pk) FROM stdin;
\.
COPY seguridad.auditoriacl (id, fecha, accion, schema, tabla, session, user_bd, data, pk) FROM '$$PATH$$/2984.dat';

--
-- Data for Name: auditoriaco; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

COPY seguridad.auditoriaco (id, fecha, accion, schema, tabla, session, user_bd, data, pk) FROM stdin;
\.
COPY seguridad.auditoriaco (id, fecha, accion, schema, tabla, session, user_bd, data, pk) FROM '$$PATH$$/2986.dat';

--
-- Data for Name: token_recuperacion; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

COPY seguridad.token_recuperacion (id, id_cliente, token, creado, vigencia) FROM stdin;
\.
COPY seguridad.token_recuperacion (id, id_cliente, token, creado, vigencia) FROM '$$PATH$$/2988.dat';

--
-- Data for Name: token_recuperacion_conductor; Type: TABLE DATA; Schema: seguridad; Owner: postgres
--

COPY seguridad.token_recuperacion_conductor (id, id_conductor, token, creado, vigencia) FROM stdin;
\.
COPY seguridad.token_recuperacion_conductor (id, id_conductor, token, creado, vigencia) FROM '$$PATH$$/2989.dat';

--
-- Name: administrador_id_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux.administrador_id_seq', 2, true);


--
-- Name: cliente_id_cliente_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux.cliente_id_cliente_seq', 13, true);


--
-- Name: conductor_id_conductor_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux.conductor_id_conductor_seq', 9, true);


--
-- Name: destino_id_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux.destino_id_seq', 10, true);


--
-- Name: estado_id_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux.estado_id_seq', 3, true);


--
-- Name: notificacion de servicio_id_cliente_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux."notificacion de servicio_id_cliente_seq"', 1, false);


--
-- Name: notificacion de servicio_id_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux."notificacion de servicio_id_seq"', 38, true);


--
-- Name: pago_id_seq; Type: SEQUENCE SET; Schema: delux; Owner: postgres
--

SELECT pg_catalog.setval('delux.pago_id_seq', 5, true);


--
-- Name: acceso_cliente_id_seq; Type: SEQUENCE SET; Schema: seguridad; Owner: postgres
--

SELECT pg_catalog.setval('seguridad.acceso_cliente_id_seq', 384, true);


--
-- Name: acceso_conductor_id_seq; Type: SEQUENCE SET; Schema: seguridad; Owner: postgres
--

SELECT pg_catalog.setval('seguridad.acceso_conductor_id_seq', 640, true);


--
-- Name: auditoriacl_id_seq; Type: SEQUENCE SET; Schema: seguridad; Owner: postgres
--

SELECT pg_catalog.setval('seguridad.auditoriacl_id_seq', 47, true);


--
-- Name: auditoriaco_id_seq; Type: SEQUENCE SET; Schema: seguridad; Owner: postgres
--

SELECT pg_catalog.setval('seguridad.auditoriaco_id_seq', 108, true);


--
-- Name: token_recuperacion_conductor_id_seq; Type: SEQUENCE SET; Schema: seguridad; Owner: postgres
--

SELECT pg_catalog.setval('seguridad.token_recuperacion_conductor_id_seq', 9, true);


--
-- Name: token_recuperacion_id_seq; Type: SEQUENCE SET; Schema: seguridad; Owner: postgres
--

SELECT pg_catalog.setval('seguridad.token_recuperacion_id_seq', 16, true);


--
-- Name: administrador administrador_pkey; Type: CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.administrador
    ADD CONSTRAINT administrador_pkey PRIMARY KEY (id);


--
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);


--
-- Name: conductor conductor_pkey; Type: CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.conductor
    ADD CONSTRAINT conductor_pkey PRIMARY KEY (id_conductor);


--
-- Name: destino destino_pkey; Type: CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.destino
    ADD CONSTRAINT destino_pkey PRIMARY KEY (id);


--
-- Name: notificacion_de_servicio notificacion de servicio_pkey; Type: CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.notificacion_de_servicio
    ADD CONSTRAINT "notificacion de servicio_pkey" PRIMARY KEY (id);


--
-- Name: pago pago_pkey; Type: CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.pago
    ADD CONSTRAINT pago_pkey PRIMARY KEY (id);


--
-- Name: estado pk_delux_estado; Type: CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.estado
    ADD CONSTRAINT pk_delux_estado PRIMARY KEY (id);


--
-- Name: acceso_cliente acceso_cliente_pkey; Type: CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.acceso_cliente
    ADD CONSTRAINT acceso_cliente_pkey PRIMARY KEY (id);


--
-- Name: acceso_conductor acceso_conductor_pkey; Type: CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.acceso_conductor
    ADD CONSTRAINT acceso_conductor_pkey PRIMARY KEY (id);


--
-- Name: auditoriacl pk_seguridad_auditoria; Type: CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.auditoriacl
    ADD CONSTRAINT pk_seguridad_auditoria PRIMARY KEY (id);


--
-- Name: auditoriaco pk_seguridad_auditoriaco; Type: CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.auditoriaco
    ADD CONSTRAINT pk_seguridad_auditoriaco PRIMARY KEY (id);


--
-- Name: token_recuperacion_conductor token_recuperacion_conductor_pkey; Type: CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.token_recuperacion_conductor
    ADD CONSTRAINT token_recuperacion_conductor_pkey PRIMARY KEY (id);


--
-- Name: token_recuperacion token_recuperacion_pkey; Type: CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.token_recuperacion
    ADD CONSTRAINT token_recuperacion_pkey PRIMARY KEY (id);


--
-- Name: fki_fk_delux_estado; Type: INDEX; Schema: delux; Owner: postgres
--

CREATE INDEX fki_fk_delux_estado ON delux.conductor USING btree (id_estado);


--
-- Name: fki_id_cliente_notificacion_de_cliente; Type: INDEX; Schema: delux; Owner: postgres
--

CREATE INDEX fki_id_cliente_notificacion_de_cliente ON delux.notificacion_de_servicio USING btree (id_cliente);


--
-- Name: fki_id_conductor_notificacion_de_servicio; Type: INDEX; Schema: delux; Owner: postgres
--

CREATE INDEX fki_id_conductor_notificacion_de_servicio ON delux.notificacion_de_servicio USING btree (id_conductor);


--
-- Name: cliente tg_delux_cliente; Type: TRIGGER; Schema: delux; Owner: postgres
--

CREATE TRIGGER tg_delux_cliente AFTER INSERT OR DELETE OR UPDATE ON delux.cliente FOR EACH ROW EXECUTE FUNCTION seguridad.f_log_auditoriacl();


--
-- Name: conductor tg_delux_conductor; Type: TRIGGER; Schema: delux; Owner: postgres
--

CREATE TRIGGER tg_delux_conductor AFTER INSERT OR DELETE OR UPDATE ON delux.conductor FOR EACH ROW EXECUTE FUNCTION seguridad.f_log_auditoriaco();


--
-- Name: conductor fk_delux_estado; Type: FK CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.conductor
    ADD CONSTRAINT fk_delux_estado FOREIGN KEY (id_estado) REFERENCES delux.estado(id) NOT VALID;


--
-- Name: notificacion_de_servicio id_cliente_notificacion_de_servicio; Type: FK CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.notificacion_de_servicio
    ADD CONSTRAINT id_cliente_notificacion_de_servicio FOREIGN KEY (id_cliente) REFERENCES delux.cliente(id_cliente) NOT VALID;


--
-- Name: notificacion_de_servicio id_conductor_notificacion_de_servicio; Type: FK CONSTRAINT; Schema: delux; Owner: postgres
--

ALTER TABLE ONLY delux.notificacion_de_servicio
    ADD CONSTRAINT id_conductor_notificacion_de_servicio FOREIGN KEY (id_conductor) REFERENCES delux.conductor(id_conductor) NOT VALID;


--
-- Name: acceso_cliente id_cliente; Type: FK CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.acceso_cliente
    ADD CONSTRAINT id_cliente FOREIGN KEY (id_cliente) REFERENCES delux.cliente(id_cliente) NOT VALID;


--
-- Name: acceso_conductor id_conductor; Type: FK CONSTRAINT; Schema: seguridad; Owner: postgres
--

ALTER TABLE ONLY seguridad.acceso_conductor
    ADD CONSTRAINT id_conductor FOREIGN KEY (id_conductor) REFERENCES delux.conductor(id_conductor) NOT VALID;


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          