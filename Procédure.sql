
--assigner un étudiant à un cours et un département 
CREATE OR REPLACE PROCEDURE student_to_course_and_departement(
p_student_id INT,
p_course_id INT,
p_departement_id INT
)

LANGUAGE plpgsql
AS $$
BEGIN
-- verificaiton de l'étudiant
IF NOT EXISTS(
    SELECT 1 FROM student WHERE student_id = p_student_id
)THEN
RAISE EXCEPTION 'ERREUR : étudiant ID % est introuvable.', p_student_id;
END IF;

--vérification du cours
IF NOT EXISTS(
    SELECT 1 FROM course WHERE course_id = p_course_id
)THEN
Raise EXCEPTION 'ERREUR : cours ID % est introuvable.', p_course_id;
END IF;

--vérification du département
IF NOT EXISTS(
    SELECT 1 FROM departement WHERE departement_id = p_departement_id
)THEN
RAISE EXCEPTION 'ERREUR : departement ID % est introuvable.',p_departement_id;
END IF;
--assigner l'étudiant au departement
INSERT INTO student_departement(student_id,departement_id)
VALUES (p_student_id, p_departement_id)
ON CONFLICT DO NOTHING;

--assigner l'étudiant au cours
INSERT INTO student_course(student_id,course_id)
VALUES(p_student_id,p_course_id)
ON CONFLICT DO NOTHING;

EXCEPTION
WHEN OTHERS THEN 
RAISE NOTICE 'ERREUR lors de l''assignation : %', SQLERRM;
END;
$$;

--Pour un cours supprimer la relation des étudiants qui on échoué le cours et ajouter ceux qui on passé au nouveau cours
CREATE OR REPLACE PROCEDURE update_student_course_on_grade(
    p_old_course_id INT,
    p_new_course_id INT
)

LANGUAGE plpgsql
AS $$ 
BEGIN
--vérification du cours initial
IF NOT EXISTS(
    SELECT 1 FROM course WHERE course_id = p_old_course_id
)THEN
RAISE EXCEPTION 'ERREUR : cours intital ID % est introuvable.', p_old_course_id;
END IF;
--vérification du cours suivant
IF NOT EXISTS(
    SELECT 1 FROM course WHERE course_id = p_new_course_id
)THEN
RAISE EXCEPTION 'ERREUR : cours suivant ID % est introuvable.',p_new_course_id;
END IF;
--supprimer les étudiant ayant un note <60
DELETE FROM student_course
WHERE course_id = p_old_course_id
AND grade IS NOT NULL
AND grade < 60;
--ajouter les étudiants ayant une note entre 60 et 100
INSERT INTO  student_course(student_id,course_id)
SELECT student_id,p_new_course_id
FROM student_course
WHERE course_id = p_old_course_id
AND grade BETWEEN 60 AND 100
ON CONFLICT DO NOTHING; 

END;
$$;

-- Exemple d’appel : assigner un étudiant à un cours et un département ou que l'étudiant n'existe pas 
CALL student_to_course_and_departement(999, 101, 10);

-- Exemple d’appel : assigner un étudiant à un cours et un département ou que le cours  n'existe pas
CALL student_to_course_and_departement(1, 999, 10);
-- Exemple d’appel : assigner un étudiant à un cours et un département ou que le département n'existe pas
CALL student_to_course_and_departement(1, 8, 999);


-- Exemple d’appel : transférer les étudiants ayant réussi vers un nouveau cours
CALL update_student_course_on_grade(999, 2);

--Exemple d’appel : transférer les étudiants ayant réussi vers un nouveau cours qui n'existe pas
CALL update_student_course_on_grade(1, 999); 