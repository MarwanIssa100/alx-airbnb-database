use alx_airbnb;
select booking_id from booking group by user_id having count(user_id) > 3 ;
select p_name from property where property_id in(select property_id from review  GROUP BY property_id HAVING AVG(rating) > 4.0);
select first_name,last_name , user_id from user where ( select count(*) from booking as b where user_id = b.user_id ) > 3;