INSERT INTO clubs (name, country, city) VALUES
('Phoenix Warriors', 'France', 'Paris'),
('Iron Titans', 'Italy', 'Milan');

select * from clubs;


select * from users;


SELECT setval(pg_get_serial_sequence('users', 'id'), (SELECT max(id) FROM users) + 1);


DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS player_payments;
DROP TABLE IF EXISTS player_equipment;
DROP TABLE IF EXISTS financials;
DROP TABLE IF EXISTS training_players;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS trainings;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS associates;
DROP TABLE IF EXISTS seasons;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS clubs;

select * from public.profiles;

select * from auth.users;

select public.handle_new_user() from auth.users;

create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = 'public'
as $$
begin
  insert into public.profiles (id, club_id, role, confirmed)
  values (new.id, null, 'parent', false);
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

DROP FUNCTION public.handle_new_user()  cascade;

