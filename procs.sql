

DELIMITER $$

CREATE PROCEDURE Selecionar_Produtos(in quantidade INT)
begin 
	select * from products limit quantidade;
end$$
DELIMITER ; 

CALL selecionar_produtos(10);

-- +++++++++++++++++++++++++++++++++++++++++++++++++++


DELIMITER $$

CREATE PROCEDURE contagem_Produtos(OUT quantidade INT)
begin 
	select count(*) from products limit quantidade;
end$$
DELIMITER ; 

CALL contagem_produtos(@total);
select @total;


-- ++++++++++++++++++++++++++++++++

DELIMITER $$

CREATE PROCEDURE multiplicar_por_elemesmo(inOUT numero INT)
begin 
	set numero = numero * numero;
end$$
DELIMITER ; 

set @valor = 5;
call multiplicar_por_elemesmo(@valor);
select @valor;
-- ++++++++++++++++++++++++++++++


