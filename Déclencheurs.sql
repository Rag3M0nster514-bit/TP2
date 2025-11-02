--Fonction pour valider
CREATE OR REPLACE FUNCTION tg_student_id_inchanger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.student_id IS DISTINCT FROM OLD.student_id THEN
    RAISE EXCEPTION 'Erreur: le matricule ne peut pas être modifié (% -> %).', OLD.student_id, NEW.student_id;
  END IF;
  RETURN NEW;
END;
$$;

-- Empêcher la modification du matricule lors d'une mise a jour
DROP TRIGGER IF EXISTS valider_student_id_before_update ON student;
CREATE TRIGGER valider_student_id_before_update
BEFORE UPDATE ON student
FOR EACH ROW
EXECUTE FUNCTION tg_student_id_inchanger();



-- empêche la création  de nouvelle TABLE
CREATE OR REPLACE FUNCTION block_create_table()
RETURNS event_trigger
LANGUAGE plpgsql
 AS $$
BEGIN
  RAISE EXCEPTION 'Erreur: La création est bloquée par la politique.';
END; $$;

DROP EVENT TRIGGER IF EXISTS et_block_create_table;
CREATE EVENT TRIGGER et_block_create_table
ON ddl_command_start
WHEN TAG IN ('CREATE TABLE')
EXECUTE FUNCTION block_create_table();

-- update TABLE
CREATE OR REPLACE FUNCTION block_update_table()
RETURNS event_trigger
LANGUAGE plpgsql
 AS $$
BEGIN
  RAISE EXCEPTION 'Erreur: La modification est bloquée par la politique.';
  RETURN NULL;
END; $$;

DROP EVENT TRIGGER IF EXISTS block_update_table;
CREATE EVENT TRIGGER _block_update_table
ON ddl_command_start
WHEN TAG IN ('ALTER TABLE')
EXECUTE FUNCTION block_update_table();

-- suppresion TABLE
CREATE OR REPLACE FUNCTION et_block_drop_table()
RETURNS event_trigger
LANGUAGE plpgsql 
AS $$
BEGIN
IF tg_tag = 'DROP TABLE' THEN
  RAISE EXCEPTION 'Erreur: La suppression est bloquée par la politique.';
END; $$;

DROP EVENT TRIGGER IF EXISTS et_block_drop_table;
CREATE EVENT TRIGGER tr_block_drop_table
ON ddl_command_start
WHEN TAG IN ('DROP TABLE')
EXECUTE FUNCTION et_block_drop_table();

--troi trigger pour departement
-- INSERT
CREATE OR REPLACE FUNCTION block_departement_insert()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'Erreur: L''insertion sur "departement" est bloquée.';
END; $$;

DROP TRIGGER IF EXISTS tr_block_departement_insert ON departement;
CREATE TRIGGER tr_block_departement_insert
BEFORE INSERT ON departement
FOR EACH ROW
EXECUTE FUNCTION block_departement_insert();

-- UPDATE
CREATE OR REPLACE FUNCTION block_departement_update()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'Erreur: La modification sur "departement" est bloquée.';
END; $$;

DROP TRIGGER IF EXISTS tr_block_update_departement ON departement;
CREATE TRIGGER tr_block_update_departement
BEFORE UPDATE ON departement
FOR EACH ROW
EXECUTE FUNCTION block_departement_update();

-- DELETE
CREATE OR REPLACE FUNCTION block_departement_delete()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'Erreur: La suppression sur "departement" est bloquée.';
END; $$;

DROP TRIGGER IF EXISTS tr_block_departement_delete ON departement;
CREATE TRIGGER tr_block_departement_delete
BEFORE DELETE ON departement
FOR EACH ROW
EXECUTE FUNCTION block_departement_delete();

--assurer qu'une note est en dessous de zéro en cas d'insertion et ou de modification
CREATE OR REPLACE FUNCTION valider_grade_non_negative()
RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.grade IS NOT NULL AND NEW.grade < 0 THEN
    RAISE EXCEPTION 'Erreur: La note ne peut pas être négative (%).', NEW.grade;
  END IF;
  RETURN NEW;
END; $$;

DROP TRIGGER IF EXISTS tr_grade_non_negative ON student_course;
CREATE TRIGGER tr_grade_non_negative
BEFORE INSERT OR UPDATE ON student_course
FOR EACH ROW
EXECUTE FUNCTION valider_grade_non_negative();
