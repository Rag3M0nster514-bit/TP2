DROP TABLE if EXISTS student CASCADE;
CREATE TABLE student (
    student_id SERIAL PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL
);
DROP TABLE if EXISTS departement CASCADE;
CREATE TABLE departement(
    departement_id  SERIAL PRIMARY KEY,
    name VARCHAR(15)
);
DROP TABLE if EXISTS course CASCADE;
CREATE TABLE course(
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL,
    sigle VARCHAR (15) UNIQUE,
    departement_id INT,  --  on déclare d’abord la colonne
    FOREIGN KEY (departement_id) REFERENCES departement(departement_id)  --  puis on crée la contrainte
);
DROP TABLE if EXISTS prof CASCADE;
CREATE TABLE prof(
    prof_id  SERIAL PRIMARY KEY,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL
);
DROP TABLE if EXISTS student_departement CASCADE;
CREATE TABLE student_departement(
    student_id INT NOT NULL,
    departement_id  INT NOT NULL,
    FOREIGN KEY (student_id)REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (departement_id)REFERENCES departement(departement_id)ON DELETE CASCADE
);
DROP TABLE if EXISTS student_course CASCADE;
CREATE TABLE student_course(
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade INT,
    FOREIGN KEY(student_id)References student(student_id)ON DELETE CASCADE,
    FOREIGN KEY(course_id) References course(course_id)ON DELETE CASCADE
);
DROP TABLE if EXISTS prof_course CASCADE;
CREATE TABLE prof_course(
    prof_id INT NOT NULL,
    course_id INT NOT NULL,
        FOREIGN KEY(prof_id)REFERENCES prof(prof_id)ON DELETE CASCADE,
        FOREIGN KEY(course_id)REFERENCES course(course_id)ON DELETE CASCADE
);