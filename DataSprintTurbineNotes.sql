
-- count of all wind turbines, double checking data source is correct
select count(*) 
from public.wind_turbine_20220114
;


select * 
from public.turbine_and_operators_2
limit 10;

-- grouping total energy produced (net gen mw hours) by operator (id)

select operator_id, operator_name, 
sum(net_generation_megawatthours)::float as net_generation_sum, 
-- we want to print out the id & name of the operator next to the sum of
--their power generation
from (
	select *               -- this is a subquery with a union of two tables
	from public.turbine_and_operators
	UNION
	select *
	from public.turbine_and_operators_2
) as unioned_turbine_operators
WHERE operator_id is not null
GROUP BY operator_id, operator_name
ORDER BY sum(net_generation_megawatthours) DESC -- sort descending
;


--checking to see how many values are in the turbine_and_operator tables
select count(distinct plant_id)
from (
	select *               -- this is a subquery with a union of two tables
	from public.turbine_and_operators
	UNION
	select *
	from public.turbine_and_operators_2
) as unioned_turbine_operators
;


--NEW Query
--finding the operators with the highest wind energy capacity in total
select operator_id, operator_name, sum(t_cap) as total_capacity_per_operator_KW
-- pull operator name & id along with the sum of wind energy capacity
from public.wind_turbine_20220114 as turbines
left join (
	select *               -- this is a subquery with a union of two tables
	from public.turbine_and_operators
	UNION
	select *
	from public.turbine_and_operators_2
) as turbine_operators
-- joined the table with operator id and name (unioned both datasets)
-- to the full list of turbines to be able to sum total capacity by
-- operator
on turbines.eia_id = turbine_operators.plant_id
--set eia_id = plant_id, need to double check this, but looks to be right
where t_cap is not null and operator_id is not null
-- removing nulls
group by operator_id, operator_name
--grouped by operators
order by sum(t_cap) desc
--ordered by descending total capacity to find operators with most
-- capacity in all of their projects
;

-- New Query, list of all owner/operators of turbines

-- Query for a query, list of OEMs

select distinct t_manu
from public.wind_turbine_20220114
limit 100;

--New Query, Capacity per OEM (manu_)

select t_manu, sum(t_cap) as OEM_Total_Capacity_KW
--pulling manufacturer name and grouping those with the sum of the
-- capacity of each of their turbines
from public.wind_turbine_20220114
-- from full turbine list
where t_manu is not null
-- filtering out all nulls
group by t_manu
-- group by OEM name
order by sum(t_cap) desc
--descending order by the total capacity, largest at the top
;


--NEW Query
--total capacity and net generation per operator
select operator_id, operator_name, sum(net_generation_megawatthours), sum(t_cap) as total_capacity_per_operator_KW
-- pull operator name & id along with the sum of wind energy capacity
from public.wind_turbine_20220114 as turbines
left join (
	select *               -- this is a subquery with a union of two tables
	from public.turbine_and_operators
	UNION
	select *
	from public.turbine_and_operators_2
) as turbine_operators
-- joined the table with operator id and name (unioned both datasets)
-- to the full list of turbines to be able to sum total capacity by
-- operator
on turbines.eia_id = turbine_operators.plant_id
--set eia_id = plant_id, need to double check this, but looks to be right
where t_cap is not null and operator_id is not null
-- removing nulls
group by operator_id, operator_name
--grouped by operators
order by sum(net_generation_megawatthours) desc
--ordered by descending total capacity to find operators with most
-- capacity in all of their projects
;



--pulling the dataset to visaualize data in tableau
--turbines by location and capacity, plus coordinates
select case_id, p_name, p_year, t_cap, xlong, ylat
from public.wind_turbine_20220114
where xlong is not null and ylat is not null and t_cap is not null
;



-- 
select operator_id, operator_name, count(*)
from public.wind_turbine_20220114 as turbines
left join (
	select *               -- this is a subquery with a union of two tables
	from public.turbine_and_operators
	UNION
	select *
	from public.turbine_and_operators_2
) as turbine_operators
on turbines.eia_id = turbine_operators.plant_id
where operator_id is not null and operator_name is not null
group by operator_id, operator_name
order by count(*) desc
;


--- new query to show the count of turbines each operator has grouped by the OEM
-- going to need an individual query for each operator I want to test
select turbines.t_manu, count(*) as turbine_from_OEM
-- selecting OEM name (t_manu), sum(*) as xyz
from public.wind_turbine_20220114 as turbines
left join (
	select *               -- this is a subquery with a union of two tables
	from public.turbine_and_operators
	UNION
	select *
	from public.turbine_and_operators_2
) as turbine_operators
on turbines.eia_id = turbine_operators.plant_id
-- from joined operator & turbine tables
where operator_id = '59050'
-- operator = xyz
group by turbines.t_manu
--t_manu
order by count(*)
-- sum(*) descending
limit 10;
--we only care about the top 5 OEMs they use

--query to pull operator id, used to then input
-- id into query above to provide oem information per operator
select operator_id, operator_name
from (select *               -- this is a subquery with a union of two tables
	from public.turbine_and_operators
	UNION
	select *
	from public.turbine_and_operators_2) as total_operators
where operator_name ilike '%Algonquin Power Co%';

