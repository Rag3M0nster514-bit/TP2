ROLLBACK;

        DO $$
        DECLARE
        i INT;
        dept_info_id INT;
        dept_math_id INT;
        dept_fr_id INT;
        prof_id INT := 1;
        course_id INT :=1;
        note NUMERIC;
        BEGIN 
        INSERT INTO departement(name) VALUES ('Informatique') returning departement_id INTO dept_info_id;
        INSERT INTO departement(name) VALUES ('Mathématique') returning departement_id INTO dept_math_id;
        INSERT INTO departement(name) VALUES ('Français') returning departement_id INTO dept_fr_id;

        --créer 10 prof
        FOR i IN 1..10 LOOP
        INSERT INTO prof(firstname,lastname) VALUES ('Prof'||i, 'Nom'||i);
        END LOOP;

        --créer 100 cours
        FOR i IN 1..100 LOOP
  INSERT INTO course(title, sigle, departement_id) VALUES(
    CASE 
      WHEN i <= 33 THEN 'Info' || i
      WHEN i <= 66 THEN 'Math' || i
      ELSE 'Fr'||  i
    END,
    'SIG' || i,
    CASE 
      WHEN i <= 33 THEN dept_info_id
      WHEN i <= 66 THEN dept_math_id
      ELSE dept_fr_id
    END
  );
END LOOP;


        -- créer 150 etudiant
        FOR i IN 1..150 LOOP
        INSERT INTO student(firstname,lastname) VALUES('Étudiant'||i , 'Nom'||i);
        INSERT INTO student_departement(student_id,departement_id)
        VALUES(
            i,
            CASE
            WHEN i <=50 THEN dept_info_id
            WHEN i <= 100 THEN dept_math_id
            ELSE dept_fr_id
            END
        );
        END LOOP;

        --1 étudiant a 8 cours
        FOR student_id IN 1..150 LOOP
        FOR course_id IN 1..8 LOOP
        INSERT INTO student_course(student_id,course_id,grade)
        VALUES(student_id,course_id,FLOOR( 50 + RANDOM()*51));
        END LOOP;
        END LOOP;

        -- 1 prof à 5 cours
        WHILE prof_id <=10 LOOP
        FOR i IN 1..5 LOOP
        INSERT INTO prof_course(prof_id, course_id)
        VALUES(prof_id,course_id);
        course_id := course_id +1;
        END LOOP;
        prof_id := prof_id +1;
        END LOOP;

        END $$;