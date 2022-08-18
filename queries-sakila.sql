 -- Lista dos Staffs com todas as informações 1 
SELECT 
  s.staff_id AS ID,
  CONCAT(s.first_name, _utf8' ', s.last_name) AS name,
  a.address AS address,
  a.postal_code AS `zip code`,
  a.phone AS phone,
  city.city AS city,
  country.country AS country,
  s.store_id AS SID
FROM staff AS s 
  JOIN address AS a ON s.address_id = a.address_id
  JOIN city ON a.city_id = city.city_id
  JOIN country ON city.country_id = country.country_id;
-- ----------------------------------------------------------------
  
  
  
-- listagem de filmes sem informações tecnicas 2
SELECT 
  film.film_id AS FID,
  film.title AS title,
  film.description AS description,
  category.name AS category,
  film.rental_rate AS price,
  film.length AS length,
  film.rating AS rating,
  GROUP_CONCAT(CONCAT(actor.first_name, _utf8' ', actor.last_name) SEPARATOR ', ') AS actors
FROM category 
  LEFT JOIN film_category ON category.category_id = film_category.category_id
  LEFT JOIN film ON film_category.film_id = film.film_id
  JOIN film_actor ON film.film_id = film_actor.film_id
  JOIN actor ON film_actor.actor_id = actor.actor_id
GROUP BY film.film_id;
-- -----------------------------------------------------------------



-- lista de filmes com as descrições e com lista de atores 3
SELECT 
  film.film_id AS FID,
  film.title AS title,
  film.description AS description,
  category.name AS category,
  film.rental_rate AS price,
  film.length AS length,
  film.rating AS rating,
  GROUP_CONCAT(
    CONCAT(
       CONCAT(UCASE(SUBSTR(actor.first_name, 1, 1)),   -- first_name initial-cap
              LCASE(SUBSTR(actor.first_name, 2, LENGTH(actor.first_name))),
       _utf8' ',                                       -- space
       CONCAT(UCASE(SUBSTR(actor.last_name, 1, 1)),    -- last_name initial-cap
              LCASE(SUBSTR(actor.last_name, 2, LENGTH(actor.last_name))))))  -- end of outer CONCAT
    SEPARATOR ', ') AS actors
FROM category 
  LEFT JOIN film_category ON category.category_id = film_category.category_id 
  LEFT JOIN film ON film_category.film_id = film.film_id
  JOIN film_actor ON film.film_id = film_actor.film_id
  JOIN actor ON film_actor.actor_id = actor.actor_id
GROUP BY film.film_id;
-- ---------------------------------------------------------------------



-- lista de vendas dos filmes por lojas e com o nome do gerente 4
SELECT
  CONCAT(c.city, _utf8',', cy.country) AS store,
  CONCAT(m.first_name, _utf8' ', m.last_name) AS manager,
  SUM(p.amount) AS total_sales
FROM payment AS p
  INNER JOIN rental AS r ON p.rental_id = r.rental_id
  INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
  INNER JOIN store AS s ON i.store_id = s.store_id
  INNER JOIN address AS a ON s.address_id = a.address_id
  INNER JOIN city AS c ON a.city_id = c.city_id
  INNER JOIN country AS cy ON c.country_id = cy.country_id
  INNER JOIN staff AS m ON s.manager_staff_id = m.staff_id
GROUP BY s.store_id
ORDER BY cy.country, c.city;
-- ------------------------------------------------------------------



-- lista de vendas por categoria do filme 5
SELECT
  c.name AS category,
  SUM(p.amount) AS total_sales
FROM payment AS p
  INNER JOIN rental AS r ON p.rental_id = r.rental_id
  INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
  INNER JOIN film AS f ON i.film_id = f.film_id
  INNER JOIN film_category AS fc ON f.film_id = fc.film_id
  INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC;
-- ------------------------------------------------------------------



-- lista de descrição dos atores 6
SELECT
  a.actor_id,
  a.first_name,
  a.last_name,
  GROUP_CONCAT(
     DISTINCT
     CONCAT(c.name, ': ',
        (SELECT 
           GROUP_CONCAT(f.title ORDER BY f.title SEPARATOR ', ')
           FROM sakila.film f
           INNER JOIN sakila.film_category fc ON f.film_id = fc.film_id
           INNER JOIN sakila.film_actor fa ON f.film_id = fa.film_id
           WHERE fc.category_id = c.category_id AND fa.actor_id = a.actor_id)
        )  -- end CONCAT
     ORDER BY c.name
     SEPARATOR '; ') AS film_info
FROM sakila.actor a
LEFT JOIN sakila.film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN sakila.film_category fc ON fa.film_id = fc.film_id
LEFT JOIN sakila.category c ON fc.category_id = c.category_id
GROUP BY
  a.actor_id,
  a.first_name,
  a.last_name;
  -- --------------------------------------------------------------------



-- Ator que fez mais filmes 7
select actor.actor_id, actor.first_name, actor.last_name,
       count(actor_id) as film_count
from actor join film_actor using (actor_id)
group by actor_id
order by film_count desc
limit 1;
-- ----------------------------------------------------------------



-- Se academy dinosaur estpa disponível na loja 1  8

select film.film_id, film.title, store.store_id, inventory.inventory_id
from inventory join store using (store_id) join film using (film_id)
where film.title = 'Academy Dinosaur' and store.store_id = 1;
-- ---------------------------------------------------------------



-- Quantos sobrenomes diferentes de atores há  9
select count(distinct last_name) from actor;
-- ----------------------------------------------------------------



-- Lista de sobrenomes que não se repetem  10  

select last_name from actor group by last_name having count(*) = 1;
-- ----------------------------------------------------------------

-- Duração dos filmes por categoria  11  
select category.name, avg(length)
from film join film_category using (film_id) join category using (category_id)
group by category.name
having avg(length) > (select avg(length) from film)
order by avg(length) desc;
-- ---------------------------------------------------------------------

-- Lançamento do filme Academy Dinosaur  12   

select rental_date,
       rental_date + interval
                   (select rental_duration from film where film_id = 1) day
                   as due_date
from rental
where rental_id = (select rental_id from rental order by rental_id desc limit 1);
-- --------------------------------------------------------------------------


-- Se Academy dinossaur está disponivel na loja 1    13 
select inventory.inventory_id
from inventory join store using (store_id)
     join film using (film_id)
     join rental using (inventory_id)
where film.title = 'Academy Dinosaur'
      and store.store_id = 1
      and not exists (select * from rental
                      where rental.inventory_id = inventory.inventory_id
                      and rental.return_date is null);
					
                    
-- --------------------------------------------------------------------------


-- inserindo o registro de uma pessoa alugando um filme     14
insert into rental (rental_date, inventory_id, customer_id, staff_id)
values (NOW(), 1, 1, 1);

-- ---------------------------------------------------------------------------


-- tempo médio de duração de todas as tabelas    15

select avg(length) from film;

-- ---------------------------------------------------------------------------

-- adicionando uma coluna de descricao na tabela de atores     16

ALTER TABLE actor
ADD COLUMN description BLOB;

-- ----------------------------------------------------------------------------


-- adicionando dados a coluna descrição    17
select * from actor;
update actor
set 
	description = 'great actors!'
where actor_id in (1, 7, 35, 100, 200, 24, 123, 8) ;

-- ---------------------------------------------------------------------------

-- Dropando a coluna de Description     18

alter table actor drop column description;

-- --------------------------------------------------------------------------

-- informações dos gerentes       19
select stf.first_name, stf.last_name, adr.address, adr.district, adr.postal_code, adr.city_id 
from staff stf
left join address adr
on stf.address_id = adr.address_id;

-- -----------------------------------------------------------------------------


-- todos os atores que aparecem no filme alone trip       20

select first_name, last_name 
from actor
where actor_id in (
	select actor_id
	from film_actor
	where film_id in (
		select film_id from film where lower(title) = lower('Alone Trip')
	)
);

-- -------------------------------------------------------------------------------

-- quantidade de negocios em dolar de cada loja      21
select A.store_id, B.sales 
from store A
join (
	select cus.store_id, sum(pay.amount) sales
	from customer cus
	join payment pay
	on pay.customer_id = cus.customer_id
group by cus.store_id
) B
on A.store_id = B.store_id
order by a.store_id;

-- --------------------------------------------------------------------------

-- Retorna as duas lojas, o id a cidade o pais e a quantidade de vendas       22
select A.*, B.sales 
from (
	select sto.store_id, cit.city, cou.country
	from store sto
	left join address adr
	on sto.address_id = adr.address_id
	join city cit
	on adr.city_id = cit.city_id
	join country cou
	on cit.country_id = cou.country_id
) A
join (
	select cus.store_id, sum(pay.amount) sales
	from customer cus
	join payment pay
	on pay.customer_id = cus.customer_id
	group by cus.store_id
) B
on A.store_id = B.store_id
order by a.store_id;

-- ------------------------------------------------------------------------


-- Filmes categorizados para família 23

select film_id, title, release_year
from film
where film_id in (
	select film_id
	from film_category
	where category_id in (
		select category_id
		from category
		where name = 'Family'
	)
);

-- ------------------------------------------------------------------------


-- Clientes que moram no canada e seus emails 24
select first_name, last_name, email
from customer
where address_id in (
	select address_id
	from address
	where city_id in (
		select city_id
		from city
		where country_id in (
			select country_id
			from country
			where country = 'Canada'
		)
	)
);
-- -------------------------------------------------------------------------



-- nome dos atores e dos clientes, tambem o seu tipo (custumer ou actor) 25

SELECT 'CUST' typ, c.first_name, c.last_name
FROM customer c
UNION ALL 
SELECT 'ACTR' typ, a.first_name, a.last_name
FROM actor a;
-- ------------------------------------------------------------


-- O nome e sobrenome de atores ou cliente que o nome seja Matthew (ator 8) 26
SELECT s.first_name,s.last_name 
FROM (
  SELECT c.first_name,c.last_name 
  FROM customer c
  UNION ALL --  --  --- - - -
  SELECT a.first_name,a.last_name 
  FROM actor a
  WHERE a.actor_id != 8
) as s
  JOIN actor a8 ON a8.first_name = s.first_name
WHERE a8.actor_id=8;

-- --------------------------------------------------------------------


-- todos os atores que aparecem no filme Academy Dinosaur 27

select first_name, last_name 
from actor
where actor_id in (
	select actor_id
	from film_actor
	where film_id in (
		select film_id from film where lower(title) = lower('Academy Dinosaur')
	)
);

-- ----------------------------------------------------------------



-- o filme que está na tabela de filmes que tem 'sandra' no first_name ou last_name da tabela de atores 28

SELECT * 
FROM film f 
INNER JOIN film_actor fa 
ON f.film_id = fa.film_id
INNER JOIN actor a
ON fa.actor_id =a.actor_id
WHERE a.first_name LIKE '%sandra%' OR a.last_name LIKE '%sandra%';



-- Quantos nomes diferentes de atores há  29
select count(distinct first_name) from actor;

-- ---------------------------------------------------------------


-- encontra o ator com mais filmes usando group by 30

SELECT first_name, last_name, count(*) films
FROM actor AS a
JOIN film_actor AS fa USING (actor_id)
GROUP BY actor_id, first_name, last_name
ORDER BY films DESC
LIMIT 1;
