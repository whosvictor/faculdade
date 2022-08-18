set @idade = 40;
    (select heart_rate,
    id,
    type, 
    minutes,
    calories,
    heart_rate,
		case
			when heart_rate > (220 - @idade) then "Acima do máximo"
            when heart_rate > (0.9 * (220 - @idade)) then "Acima do objetivo"
            when heart_rate > (0.5 * (220 - @idade)) then "Dentro do objetivo"
			ELSE "Abaixo do objetivo" 
		END AS HR_ZONE
        FROM exercise_logs) 
