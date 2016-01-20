DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id    INTEGER       PRIMARY KEY,
  fname VARCHAR(255)  NOT NULL,
  lname VARCHAR(255)  NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id        INTEGER       PRIMARY KEY,
  title     VARCHAR(255)  NOT NULL,
  body      TEXT          NOT NULL,
  author_id INTEGER       NOT NULL,
  FOREIGN KEY(author_id)  REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  id          INTEGER PRIMARY KEY,
  user_id     INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id)     REFERENCES users(id)

);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id          INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id     INTEGER NOT NULL,
  reply_id    INTEGER,
  body        TEXT,
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(reply_id)    REFERENCES replies(id),
  FOREIGN KEY(user_id)     REFERENCES users(id)

);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  id          INTEGER PRIMARY KEY,
  user_id     INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id)     REFERENCES users(id)
);

INSERT INTO
  users ( fname, lname )
VALUES
  ( 'Sam', 'Gerber' ),
  ( 'Scott', 'Kwang' ),
  ( 'Max', 'Schram' ),
  ( 'Asher', 'Abramson' );

INSERT INTO
  questions ( title, body, author_id )
VALUES
  ( 'Weather', 'Is it raining?', 1 ),
  ( 'Weather', 'Is it sunny?', 1 ),
  ( 'Questions', 'How many are there?', 2 ),
  ( 'Books', 'Which one is best?', 3 );

INSERT INTO
  question_follows ( user_id, question_id )
VALUES
  ( 1 , 1 ),
  ( 1 , 2 ),
  ( 1 , 3 ),
  ( 2 , 1 ),
  ( 2 , 1 ),
  ( 3 , 1 ),
  ( 3 , 3 ),
  ( 3 , 4 );

INSERT INTO
  replies ( question_id, user_id, reply_id, body)
VALUES
  ( 1, 2, NULL, 'I do not know'),
  ( 1, 3,    1, 'It is raining'),
  ( 3, 4, NULL, 'Do not read. It is STOOPID!');

INSERT INTO
  question_likes ( user_id, question_id )
VALUES
  ( 1 , 4 ),
  ( 1 , 3 ),
  ( 2 , 1 ),
  ( 2 , 2 ),
  ( 4 , 1 );
