ROLLBACK;

-- calculer la moyenne globale des étudiant dans un cours spécifique d'un prof spécifique
CREATE OR REPLACE FUNCTION note_moyenne_de_prof_par_cours(
    p_prof_id INT,
    p_course_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
avg_grade NUMERIC;
BEGIN
--vérification du prof
IF NOT EXISTS(
    SELECT 1 FROM prof WHERE prof_id = p_prof_id
)THEN
RAISE EXCEPTION 'ERREUR : prof ID % est introuvable.',p_prof_id;
END IF;
--vérification du cours
IF NOT EXISTS(
    SELECT 1 FROM course WHERE course_id = p_course_id
)THEN
RAISE EXCEPTION ' ERREUR : cours ID % est introuvable.',p_course_id;
END IF;
--vérification de l'assosiation prof-cours
IF NOT EXISTS(
    SELECT 1 FROM prof_course WHERE prof_id=p_prof_id AND course_id = p_course_id
)THEN
RAISE EXCEPTION 'ERREUR : le cours ID % n''est pas assigné au prof ID %.',p_prof_id,p_course_id;
END IF;
--calculer la moyenne
SELECT AVG(grade)
INTO avg_grade
FROM student_course
WHERE course_id = p_course_id AND grade IS NOT NULL;
RETURN avg_grade;
END ;
$$;

--Retourner tous les prof d'un département et renvoyer le nombre de cours géres par eux
CREATE OR REPLACE FUNCTION prof_course_count_by_departement(
    p_departement_id INT
)
RETURNS TABLE(
    prof_id INT,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    course_count INT
)
LANGUAGE plpgsql
AS $$
BEGIN

--vérification du département
IF NOT EXISTS (
    SELECT 1 FROM departement WHERE departement_id=p_departement_id
)THEN
RAISE EXCEPTION 'ERREUR : le departement ID % est introuvable.',p_departement_id;
END IF;

RETURN QUERY 
SELECT p.prof_id,p.firstname,p.lastname, COUNT(pc.course_id) AS course_count
FROM prof p
JOIN prof_course pc ON p.prof_id= pc.prof_id
JOIN course c ON pc.course_id = c.course_id
WHERE c.departement_id = p_departement_id GROUP BY p.prof_id, p.firstname,p.lastname;
END;
$$;

--Erreur : prof ID introuvable
ELECT note_moyenne_de_prof_par_cours(999, 101);

--Erreur : course ID introuvable
SELECT note_moyenne_de_prof_par_cours(1, 999);

--Erreur : cours non assigné au prof
SELECT note_moyenne_de_prof_par_cours(1, 102); -- 102 existe mais n’est pas lié au prof 1

--Erreur : département ID introuvable
SELECT * FROM prof_course_count_by_departement(999);