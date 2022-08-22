SELECT customers.name ,customers.email, orders.item, orders.price 
FROM customers
LEFT OUTER JOIN orders
ON customers.id= orders.customer_id
AND customers.item is null;
