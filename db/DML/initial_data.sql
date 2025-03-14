-- insert 2 clubs
INSERT INTO clubs (name, country, city) VALUES
('Phoenix Warriors', 'France', 'Paris'),
('Iron Titans', 'Italy', 'Milan');


-- insert 3 teams for 2 clubs
INSERT INTO teams (club_id, name) VALUES
(1, 'U7'),
(1, 'U8'),
(1, 'U9'),
(2, 'U10'),
(2, 'U11'),
(2, 'U12');

select * from clubs;

select * from profiles


-- Insert players for Club 1, 2 players per team
INSERT INTO public.players (club_id, first_name, last_name, birth_date, position, team_id, contact, address, city, nationality, guardian_name, guardian_contact)
VALUES
  (1, 'John', 'Doe', '2008-01-01', 'FW', 5, '1234567890', '123 Main St', 'City A', 'Country A', 'Jane Doe', '9876543210'),
  (1, 'Alice', 'Smith', '2008-02-01', 'MF', 5, '1234567891', '124 Main St', 'City A', 'Country A', 'Tom Smith', '9876543211'),
  (1, 'Bob', 'Brown', '2008-03-01', 'GK', 6, '1234567892', '125 Main St', 'City A', 'Country A', 'Lucy Brown', '9876543212'),
  (1, 'Charlie', 'Davis', '2008-04-01', 'DF', 6, '1234567893', '126 Main St', 'City A', 'Country A', 'Sam Davis', '9876543213'),
  (1, 'Eve', 'Taylor', '2008-05-01', 'FW', 7, '1234567894', '127 Main St', 'City A', 'Country A', 'Eva Taylor', '9876543214'),
  (1, 'David', 'Wilson', '2008-06-01', 'MF', 7, '1234567895', '128 Main St', 'City A', 'Country A', 'David Wilson', '9876543215');


-- Insert players for Club 2, 2 players per team
INSERT INTO public.players (club_id, first_name, last_name, birth_date, position, team_id, contact, address, city, nationality, guardian_name, guardian_contact)
VALUES
  (2, 'Michael', 'Johnson', '2008-01-01', 'FW', 8, '2234567890', '200 Main St', 'City B', 'Country B', 'Sara Johnson', '9876543220'),
  (2, 'Sophia', 'Lee', '2008-02-01', 'MF', 8, '2234567891', '201 Main St', 'City B', 'Country B', 'John Lee', '9876543221'),
  (2, 'James', 'Garcia', '2008-03-01', 'GK', 9, '2234567892', '202 Main St', 'City B', 'Country B', 'Emily Garcia', '9876543222'),
  (2, 'Olivia', 'Martinez', '2008-04-01', 'DF', 9, '2234567893', '203 Main St', 'City B', 'Country B', 'Carlos Martinez', '9876543223'),
  (2, 'Liam', 'Rodriguez', '2008-05-01', 'FW', 10, '2234567894', '204 Main St', 'City B', 'Country B', 'Linda Rodriguez', '9876543224'),
  (2, 'Mia', 'Hernandez', '2008-06-01', 'MF', 10, '2234567895', '205 Main St', 'City B', 'Country B', 'Marco Hernandez', '9876543225');


select * from profiles;